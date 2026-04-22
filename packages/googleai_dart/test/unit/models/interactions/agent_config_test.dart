import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DeepResearchVisualization', () {
    test('deepResearchVisualizationFromString converts known values', () {
      expect(
        deepResearchVisualizationFromString('off'),
        DeepResearchVisualization.off,
      );
      expect(
        deepResearchVisualizationFromString('auto'),
        DeepResearchVisualization.auto,
      );
    });

    test('deepResearchVisualizationFromString returns null for unknown', () {
      expect(deepResearchVisualizationFromString(null), isNull);
      expect(deepResearchVisualizationFromString(''), isNull);
      expect(deepResearchVisualizationFromString('future_value'), isNull);
      expect(deepResearchVisualizationFromString('OFF'), isNull);
    });

    test('deepResearchVisualizationToString converts all enum values', () {
      expect(
        deepResearchVisualizationToString(DeepResearchVisualization.off),
        'off',
      );
      expect(
        deepResearchVisualizationToString(DeepResearchVisualization.auto),
        'auto',
      );
    });

    test('round-trip for all values', () {
      for (final value in DeepResearchVisualization.values) {
        expect(
          deepResearchVisualizationFromString(
            deepResearchVisualizationToString(value),
          ),
          value,
        );
      }
    });
  });

  group('DeepResearchAgentConfig', () {
    group('constructor', () {
      test('creates with all new fields', () {
        const config = DeepResearchAgentConfig(
          thinkingSummaries: InteractionThinkingSummaries.auto,
          collaborativePlanning: true,
          visualization: DeepResearchVisualization.auto,
        );
        expect(config.type, 'deep-research');
        expect(config.thinkingSummaries, InteractionThinkingSummaries.auto);
        expect(config.collaborativePlanning, isTrue);
        expect(config.visualization, DeepResearchVisualization.auto);
      });

      test('creates with no fields', () {
        const config = DeepResearchAgentConfig();
        expect(config.thinkingSummaries, isNull);
        expect(config.collaborativePlanning, isNull);
        expect(config.visualization, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'type': 'deep-research',
          'thinking_summaries': 'auto',
          'collaborative_planning': true,
          'visualization': 'off',
        };
        final config = DeepResearchAgentConfig.fromJson(json);
        expect(config.thinkingSummaries, InteractionThinkingSummaries.auto);
        expect(config.collaborativePlanning, isTrue);
        expect(config.visualization, DeepResearchVisualization.off);
      });

      test('deserializes via sealed AgentConfig.fromJson', () {
        final json = {
          'type': 'deep-research',
          'collaborative_planning': false,
          'visualization': 'auto',
        };
        final config = AgentConfig.fromJson(json);
        expect(config, isA<DeepResearchAgentConfig>());
        final deep = config as DeepResearchAgentConfig;
        expect(deep.collaborativePlanning, isFalse);
        expect(deep.visualization, DeepResearchVisualization.auto);
      });

      test('tolerates unrecognized visualization value', () {
        final json = {'type': 'deep-research', 'visualization': 'future_value'};
        final config = DeepResearchAgentConfig.fromJson(json);
        expect(config.visualization, isNull);
      });
    });

    group('toJson', () {
      test('serializes all set fields with snake_case keys', () {
        const config = DeepResearchAgentConfig(
          thinkingSummaries: InteractionThinkingSummaries.none,
          collaborativePlanning: true,
          visualization: DeepResearchVisualization.auto,
        );
        final json = config.toJson();
        expect(json['type'], 'deep-research');
        expect(json['thinking_summaries'], 'none');
        expect(json['collaborative_planning'], isTrue);
        expect(json['visualization'], 'auto');
      });

      test('omits null fields', () {
        const config = DeepResearchAgentConfig();
        final json = config.toJson();
        expect(json, {'type': 'deep-research'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves all fields', () {
        final original = {
          'type': 'deep-research',
          'thinking_summaries': 'auto',
          'collaborative_planning': true,
          'visualization': 'off',
        };
        final result = DeepResearchAgentConfig.fromJson(original).toJson();
        expect(result, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        const config = DeepResearchAgentConfig(
          collaborativePlanning: true,
          visualization: DeepResearchVisualization.auto,
        );
        final copy = config.copyWith();
        expect(copy.collaborativePlanning, isTrue);
        expect(copy.visualization, DeepResearchVisualization.auto);
      });

      test('copies with updated fields', () {
        const config = DeepResearchAgentConfig(
          visualization: DeepResearchVisualization.off,
        );
        final copy = config.copyWith(
          visualization: DeepResearchVisualization.auto,
          collaborativePlanning: true,
        );
        expect(copy.visualization, DeepResearchVisualization.auto);
        expect(copy.collaborativePlanning, isTrue);
      });

      test('copies with null to clear fields', () {
        const config = DeepResearchAgentConfig(
          collaborativePlanning: true,
          visualization: DeepResearchVisualization.auto,
        );
        final copy = config.copyWith(
          collaborativePlanning: null,
          visualization: null,
        );
        expect(copy.collaborativePlanning, isNull);
        expect(copy.visualization, isNull);
      });
    });
  });
}
