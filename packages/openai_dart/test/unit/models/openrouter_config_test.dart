import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OpenRouterProviderPreferences', () {
    test('fromJson parses all fields', () {
      final json = {
        'order': ['OpenAI', 'Azure'],
        'allow_fallbacks': true,
        'require_parameters': false,
        'data_collection': 'deny',
        'zdr': true,
        'ignore': ['Anthropic'],
        'quantizations': ['fp16', 'bf16'],
        'sort': 'price',
      };

      final prefs = OpenRouterProviderPreferences.fromJson(json);

      expect(prefs.order, ['OpenAI', 'Azure']);
      expect(prefs.allowFallbacks, true);
      expect(prefs.requireParameters, false);
      expect(prefs.dataCollection, 'deny');
      expect(prefs.zdr, true);
      expect(prefs.ignore, ['Anthropic']);
      expect(prefs.quantizations, ['fp16', 'bf16']);
      expect(prefs.sort, 'price');
    });

    test('toJson produces correct output', () {
      const prefs = OpenRouterProviderPreferences(
        order: ['OpenAI'],
        allowFallbacks: false,
        sort: 'latency',
      );

      final json = prefs.toJson();

      expect(json['order'], ['OpenAI']);
      expect(json['allow_fallbacks'], false);
      expect(json['sort'], 'latency');
      expect(json.containsKey('zdr'), false); // null fields excluded
    });

    test('fromJson handles partial fields', () {
      final json = {
        'order': ['OpenAI'],
      };

      final prefs = OpenRouterProviderPreferences.fromJson(json);

      expect(prefs.order, ['OpenAI']);
      expect(prefs.allowFallbacks, isNull);
      expect(prefs.requireParameters, isNull);
    });

    test('equality works correctly', () {
      const prefs1 = OpenRouterProviderPreferences(
        order: ['OpenAI'],
        allowFallbacks: true,
      );
      const prefs2 = OpenRouterProviderPreferences(
        order: ['OpenAI'],
        allowFallbacks: true,
      );
      const prefs3 = OpenRouterProviderPreferences(
        order: ['Azure'],
        allowFallbacks: true,
      );

      expect(prefs1, equals(prefs2));
      expect(prefs1, isNot(equals(prefs3)));
    });
  });

  group('OpenRouterUsageConfig', () {
    test('fromJson parses correctly', () {
      final json = {'include': true};

      final config = OpenRouterUsageConfig.fromJson(json);

      expect(config.include, true);
    });

    test('toJson produces correct output', () {
      const config = OpenRouterUsageConfig(include: true);

      final json = config.toJson();

      expect(json['include'], true);
    });

    test('handles empty json', () {
      final json = <String, dynamic>{};

      final config = OpenRouterUsageConfig.fromJson(json);

      expect(config.include, isNull);
    });

    test('equality works correctly', () {
      const config1 = OpenRouterUsageConfig(include: true);
      const config2 = OpenRouterUsageConfig(include: true);
      const config3 = OpenRouterUsageConfig(include: false);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('OpenRouterReasoning', () {
    test('fromJson parses all fields', () {
      final json = {
        'effort': 'high',
        'max_tokens': 8000,
        'exclude': false,
        'enabled': true,
      };

      final reasoning = OpenRouterReasoning.fromJson(json);

      expect(reasoning.effort, 'high');
      expect(reasoning.maxTokens, 8000);
      expect(reasoning.exclude, false);
      expect(reasoning.enabled, true);
    });

    test('toJson produces correct output', () {
      const reasoning = OpenRouterReasoning(effort: 'medium', maxTokens: 4000);

      final json = reasoning.toJson();

      expect(json['effort'], 'medium');
      expect(json['max_tokens'], 4000);
      expect(json.containsKey('exclude'), false); // null fields excluded
    });

    test('handles partial fields', () {
      final json = {'effort': 'low'};

      final reasoning = OpenRouterReasoning.fromJson(json);

      expect(reasoning.effort, 'low');
      expect(reasoning.maxTokens, isNull);
      expect(reasoning.exclude, isNull);
      expect(reasoning.enabled, isNull);
    });

    test('equality works correctly', () {
      const r1 = OpenRouterReasoning(effort: 'high', maxTokens: 8000);
      const r2 = OpenRouterReasoning(effort: 'high', maxTokens: 8000);
      const r3 = OpenRouterReasoning(effort: 'low', maxTokens: 8000);

      expect(r1, equals(r2));
      expect(r1, isNot(equals(r3)));
    });
  });
}
