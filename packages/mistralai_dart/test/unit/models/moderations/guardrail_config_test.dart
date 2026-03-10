import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ModerationLLMV1Action', () {
    test('has correct values', () {
      expect(ModerationLLMV1Action.block.value, 'block');
      expect(ModerationLLMV1Action.none.value, 'none');
    });

    test('fromString returns correct enum', () {
      expect(
        ModerationLLMV1Action.fromString('block'),
        ModerationLLMV1Action.block,
      );
      expect(
        ModerationLLMV1Action.fromString('none'),
        ModerationLLMV1Action.none,
      );
    });

    test('fromString defaults to none for unknown values', () {
      expect(
        ModerationLLMV1Action.fromString('unknown'),
        ModerationLLMV1Action.none,
      );
      expect(
        ModerationLLMV1Action.fromString(null),
        ModerationLLMV1Action.none,
      );
    });
  });

  group('ModerationLLMV1CategoryThresholds', () {
    group('constructor', () {
      test('creates with no parameters', () {
        const thresholds = ModerationLLMV1CategoryThresholds();
        expect(thresholds.dangerousAndCriminalContent, isNull);
        expect(thresholds.financial, isNull);
        expect(thresholds.hateAndDiscrimination, isNull);
        expect(thresholds.health, isNull);
        expect(thresholds.law, isNull);
        expect(thresholds.pii, isNull);
        expect(thresholds.selfharm, isNull);
        expect(thresholds.sexual, isNull);
        expect(thresholds.violenceAndThreats, isNull);
      });

      test('creates with all parameters', () {
        const thresholds = ModerationLLMV1CategoryThresholds(
          dangerousAndCriminalContent: 0.1,
          financial: 0.2,
          hateAndDiscrimination: 0.3,
          health: 0.4,
          law: 0.5,
          pii: 0.6,
          selfharm: 0.7,
          sexual: 0.8,
          violenceAndThreats: 0.9,
        );
        expect(thresholds.dangerousAndCriminalContent, 0.1);
        expect(thresholds.financial, 0.2);
        expect(thresholds.hateAndDiscrimination, 0.3);
        expect(thresholds.health, 0.4);
        expect(thresholds.law, 0.5);
        expect(thresholds.pii, 0.6);
        expect(thresholds.selfharm, 0.7);
        expect(thresholds.sexual, 0.8);
        expect(thresholds.violenceAndThreats, 0.9);
      });
    });

    group('toJson', () {
      test('serializes empty thresholds to empty map', () {
        const thresholds = ModerationLLMV1CategoryThresholds();
        final json = thresholds.toJson();
        expect(json, isEmpty);
      });

      test('serializes all fields', () {
        const thresholds = ModerationLLMV1CategoryThresholds(
          dangerousAndCriminalContent: 0.1,
          financial: 0.2,
          hateAndDiscrimination: 0.3,
          health: 0.4,
          law: 0.5,
          pii: 0.6,
          selfharm: 0.7,
          sexual: 0.8,
          violenceAndThreats: 0.9,
        );
        final json = thresholds.toJson();
        expect(json['dangerous_and_criminal_content'], 0.1);
        expect(json['financial'], 0.2);
        expect(json['hate_and_discrimination'], 0.3);
        expect(json['health'], 0.4);
        expect(json['law'], 0.5);
        expect(json['pii'], 0.6);
        expect(json['selfharm'], 0.7);
        expect(json['sexual'], 0.8);
        expect(json['violence_and_threats'], 0.9);
      });

      test('omits null fields', () {
        const thresholds = ModerationLLMV1CategoryThresholds(pii: 0.5);
        final json = thresholds.toJson();
        expect(json.containsKey('dangerous_and_criminal_content'), isFalse);
        expect(json.containsKey('financial'), isFalse);
        expect(json.containsKey('hate_and_discrimination'), isFalse);
        expect(json.containsKey('health'), isFalse);
        expect(json.containsKey('law'), isFalse);
        expect(json['pii'], 0.5);
        expect(json.containsKey('selfharm'), isFalse);
        expect(json.containsKey('sexual'), isFalse);
        expect(json.containsKey('violence_and_threats'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'dangerous_and_criminal_content': 0.1,
          'financial': 0.2,
          'hate_and_discrimination': 0.3,
          'health': 0.4,
          'law': 0.5,
          'pii': 0.6,
          'selfharm': 0.7,
          'sexual': 0.8,
          'violence_and_threats': 0.9,
        };
        final thresholds = ModerationLLMV1CategoryThresholds.fromJson(json);
        expect(thresholds.dangerousAndCriminalContent, 0.1);
        expect(thresholds.financial, 0.2);
        expect(thresholds.hateAndDiscrimination, 0.3);
        expect(thresholds.health, 0.4);
        expect(thresholds.law, 0.5);
        expect(thresholds.pii, 0.6);
        expect(thresholds.selfharm, 0.7);
        expect(thresholds.sexual, 0.8);
        expect(thresholds.violenceAndThreats, 0.9);
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final thresholds = ModerationLLMV1CategoryThresholds.fromJson(json);
        expect(thresholds.dangerousAndCriminalContent, isNull);
        expect(thresholds.financial, isNull);
        expect(thresholds.hateAndDiscrimination, isNull);
        expect(thresholds.health, isNull);
        expect(thresholds.law, isNull);
        expect(thresholds.pii, isNull);
        expect(thresholds.selfharm, isNull);
        expect(thresholds.sexual, isNull);
        expect(thresholds.violenceAndThreats, isNull);
      });

      test('handles integer values as doubles', () {
        final json = <String, dynamic>{'pii': 1, 'health': 0};
        final thresholds = ModerationLLMV1CategoryThresholds.fromJson(json);
        expect(thresholds.pii, 1.0);
        expect(thresholds.health, 0.0);
      });
    });

    group('equality', () {
      test('equals with same values', () {
        const t1 = ModerationLLMV1CategoryThresholds(pii: 0.5, health: 0.3);
        const t2 = ModerationLLMV1CategoryThresholds(pii: 0.5, health: 0.3);
        expect(t1, equals(t2));
        expect(t1.hashCode, equals(t2.hashCode));
      });

      test('not equals with different values', () {
        const t1 = ModerationLLMV1CategoryThresholds(pii: 0.5);
        const t2 = ModerationLLMV1CategoryThresholds(pii: 0.6);
        expect(t1, isNot(equals(t2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const thresholds = ModerationLLMV1CategoryThresholds(pii: 0.5);
        expect(
          thresholds.toString(),
          contains('ModerationLLMV1CategoryThresholds'),
        );
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = ModerationLLMV1CategoryThresholds(
          dangerousAndCriminalContent: 0.1,
          financial: 0.2,
          hateAndDiscrimination: 0.3,
          health: 0.4,
          law: 0.5,
          pii: 0.6,
          selfharm: 0.7,
          sexual: 0.8,
          violenceAndThreats: 0.9,
        );
        final json = original.toJson();
        final restored = ModerationLLMV1CategoryThresholds.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });

  group('ModerationLLMV1Config', () {
    group('constructor', () {
      test('creates with no parameters', () {
        const config = ModerationLLMV1Config();
        expect(config.action, isNull);
        expect(config.customCategoryThresholds, isNull);
        expect(config.ignoreOtherCategories, isNull);
        expect(config.modelName, isNull);
      });

      test('creates with all parameters', () {
        const config = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
          customCategoryThresholds: ModerationLLMV1CategoryThresholds(pii: 0.5),
          ignoreOtherCategories: true,
          modelName: 'mistral-moderation-latest',
        );
        expect(config.action, ModerationLLMV1Action.block);
        expect(config.customCategoryThresholds?.pii, 0.5);
        expect(config.ignoreOtherCategories, true);
        expect(config.modelName, 'mistral-moderation-latest');
      });
    });

    group('toJson', () {
      test('serializes empty config to empty map', () {
        const config = ModerationLLMV1Config();
        final json = config.toJson();
        expect(json, isEmpty);
        expect(json.containsKey('action'), isFalse);
        expect(json.containsKey('custom_category_thresholds'), isFalse);
        expect(json.containsKey('ignore_other_categories'), isFalse);
        expect(json.containsKey('model_name'), isFalse);
      });

      test('serializes all fields', () {
        const config = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
          customCategoryThresholds: ModerationLLMV1CategoryThresholds(pii: 0.5),
          ignoreOtherCategories: true,
          modelName: 'mistral-moderation-latest',
        );
        final json = config.toJson();
        expect(json['action'], 'block');
        expect(json['custom_category_thresholds'], isA<Map<String, dynamic>>());
        expect((json['custom_category_thresholds'] as Map)['pii'], 0.5);
        expect(json['ignore_other_categories'], true);
        expect(json['model_name'], 'mistral-moderation-latest');
      });

      test('omits null fields', () {
        const config = ModerationLLMV1Config(
          action: ModerationLLMV1Action.none,
        );
        final json = config.toJson();
        expect(json['action'], 'none');
        expect(json.containsKey('custom_category_thresholds'), isFalse);
        expect(json.containsKey('ignore_other_categories'), isFalse);
        expect(json.containsKey('model_name'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'action': 'block',
          'custom_category_thresholds': {'pii': 0.5},
          'ignore_other_categories': true,
          'model_name': 'mistral-moderation-latest',
        };
        final config = ModerationLLMV1Config.fromJson(json);
        expect(config.action, ModerationLLMV1Action.block);
        expect(config.customCategoryThresholds?.pii, 0.5);
        expect(config.ignoreOtherCategories, true);
        expect(config.modelName, 'mistral-moderation-latest');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final config = ModerationLLMV1Config.fromJson(json);
        expect(config.action, isNull);
        expect(config.customCategoryThresholds, isNull);
        expect(config.ignoreOtherCategories, isNull);
        expect(config.modelName, isNull);
      });
    });

    group('equality', () {
      test('equals with same values', () {
        const config1 = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
          modelName: 'model-a',
        );
        const config2 = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
          modelName: 'model-a',
        );
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('not equals with different values', () {
        const config1 = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
        );
        const config2 = ModerationLLMV1Config(
          action: ModerationLLMV1Action.none,
        );
        expect(config1, isNot(equals(config2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const config = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
          modelName: 'test-model',
        );
        final str = config.toString();
        expect(str, contains('ModerationLLMV1Config'));
        expect(str, contains('modelName'));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = ModerationLLMV1Config(
          action: ModerationLLMV1Action.block,
          customCategoryThresholds: ModerationLLMV1CategoryThresholds(
            pii: 0.5,
            health: 0.3,
          ),
          ignoreOtherCategories: true,
          modelName: 'mistral-moderation-latest',
        );
        final json = original.toJson();
        final restored = ModerationLLMV1Config.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });

  group('GuardrailConfig', () {
    group('constructor', () {
      test('creates with defaults', () {
        const config = GuardrailConfig();
        expect(config.blockOnError, false);
        expect(config.moderationLlmV1, isNull);
      });

      test('creates with all parameters', () {
        const config = GuardrailConfig(
          blockOnError: true,
          moderationLlmV1: ModerationLLMV1Config(
            action: ModerationLLMV1Action.block,
          ),
        );
        expect(config.blockOnError, true);
        expect(config.moderationLlmV1?.action, ModerationLLMV1Action.block);
      });
    });

    group('toJson', () {
      test('serializes with defaults', () {
        const config = GuardrailConfig();
        final json = config.toJson();
        expect(json['block_on_error'], false);
        expect(json.containsKey('moderation_llm_v1'), isFalse);
      });

      test('serializes all fields', () {
        const config = GuardrailConfig(
          blockOnError: true,
          moderationLlmV1: ModerationLLMV1Config(
            action: ModerationLLMV1Action.block,
          ),
        );
        final json = config.toJson();
        expect(json['block_on_error'], true);
        expect(json['moderation_llm_v1'], isA<Map<String, dynamic>>());
        expect((json['moderation_llm_v1'] as Map)['action'], 'block');
      });

      test('omits null moderationLlmV1', () {
        const config = GuardrailConfig(blockOnError: true);
        final json = config.toJson();
        expect(json.containsKey('moderation_llm_v1'), isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = <String, dynamic>{
          'block_on_error': true,
          'moderation_llm_v1': {'action': 'block', 'model_name': 'test-model'},
        };
        final config = GuardrailConfig.fromJson(json);
        expect(config.blockOnError, true);
        expect(config.moderationLlmV1?.action, ModerationLLMV1Action.block);
        expect(config.moderationLlmV1?.modelName, 'test-model');
      });

      test('handles missing optional fields', () {
        final json = <String, dynamic>{};
        final config = GuardrailConfig.fromJson(json);
        expect(config.blockOnError, false);
        expect(config.moderationLlmV1, isNull);
      });

      test('defaults blockOnError to false when missing', () {
        final json = <String, dynamic>{
          'moderation_llm_v1': {'action': 'none'},
        };
        final config = GuardrailConfig.fromJson(json);
        expect(config.blockOnError, false);
        expect(config.moderationLlmV1?.action, ModerationLLMV1Action.none);
      });
    });

    group('equality', () {
      test('equals with same values', () {
        const config1 = GuardrailConfig(
          blockOnError: true,
          moderationLlmV1: ModerationLLMV1Config(
            action: ModerationLLMV1Action.block,
          ),
        );
        const config2 = GuardrailConfig(
          blockOnError: true,
          moderationLlmV1: ModerationLLMV1Config(
            action: ModerationLLMV1Action.block,
          ),
        );
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('not equals with different values', () {
        const config1 = GuardrailConfig(blockOnError: true);
        const config2 = GuardrailConfig(blockOnError: false);
        expect(config1, isNot(equals(config2)));
      });
    });

    group('toString', () {
      test('returns descriptive string', () {
        const config = GuardrailConfig(blockOnError: true);
        final str = config.toString();
        expect(str, contains('GuardrailConfig'));
        expect(str, contains('blockOnError'));
      });
    });

    group('round-trip serialization', () {
      test('preserves all data through JSON round-trip', () {
        const original = GuardrailConfig(
          blockOnError: true,
          moderationLlmV1: ModerationLLMV1Config(
            action: ModerationLLMV1Action.block,
            customCategoryThresholds: ModerationLLMV1CategoryThresholds(
              pii: 0.5,
            ),
            ignoreOtherCategories: true,
            modelName: 'mistral-moderation-latest',
          ),
        );
        final json = original.toJson();
        final restored = GuardrailConfig.fromJson(json);
        expect(restored, equals(original));
      });

      test('preserves default config through JSON round-trip', () {
        const original = GuardrailConfig();
        final json = original.toJson();
        final restored = GuardrailConfig.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });
}
