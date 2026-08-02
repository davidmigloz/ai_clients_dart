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
          enableBigqueryTool: true,
          visualization: DeepResearchVisualization.auto,
        );
        expect(config.type, 'deep-research');
        expect(config.thinkingSummaries, InteractionThinkingSummaries.auto);
        expect(config.collaborativePlanning, isTrue);
        expect(config.enableBigqueryTool, isTrue);
        expect(config.visualization, DeepResearchVisualization.auto);
      });

      test('creates with no fields', () {
        const config = DeepResearchAgentConfig();
        expect(config.thinkingSummaries, isNull);
        expect(config.collaborativePlanning, isNull);
        expect(config.enableBigqueryTool, isNull);
        expect(config.visualization, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'type': 'deep-research',
          'thinking_summaries': 'auto',
          'collaborative_planning': true,
          'enable_bigquery_tool': true,
          'visualization': 'off',
        };
        final config = DeepResearchAgentConfig.fromJson(json);
        expect(config.thinkingSummaries, InteractionThinkingSummaries.auto);
        expect(config.collaborativePlanning, isTrue);
        expect(config.enableBigqueryTool, isTrue);
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
          enableBigqueryTool: true,
          visualization: DeepResearchVisualization.auto,
        );
        final json = config.toJson();
        expect(json['type'], 'deep-research');
        expect(json['thinking_summaries'], 'none');
        expect(json['collaborative_planning'], isTrue);
        expect(json['enable_bigquery_tool'], isTrue);
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

  group('FindRequestMode', () {
    test('findRequestModeFromString converts known values', () {
      expect(findRequestModeFromString('scan'), FindRequestMode.scan);
      expect(findRequestModeFromString('verify'), FindRequestMode.verify);
    });

    test('findRequestModeFromString returns null for unknown', () {
      expect(findRequestModeFromString(null), isNull);
      expect(findRequestModeFromString('future_value'), isNull);
    });

    test('findRequestModeToString converts all enum values', () {
      expect(findRequestModeToString(FindRequestMode.scan), 'scan');
      expect(findRequestModeToString(FindRequestMode.verify), 'verify');
    });
  });

  group('AntigravityAgentConfig', () {
    group('constructor', () {
      test('creates with all fields', () {
        const config = AntigravityAgentConfig(
          maxTotalTokens: '1000000',
          model: 'gemini-3.5-flash',
        );
        expect(config.type, 'antigravity');
        expect(config.maxTotalTokens, '1000000');
        expect(config.model, 'gemini-3.5-flash');
      });

      test('creates with no fields', () {
        const config = AntigravityAgentConfig();
        expect(config.maxTotalTokens, isNull);
        expect(config.model, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields', () {
        final json = {
          'type': 'antigravity',
          'max_total_tokens': '500000',
          'model': 'gemini-3.5-pro',
        };
        final config = AntigravityAgentConfig.fromJson(json);
        expect(config.maxTotalTokens, '500000');
        expect(config.model, 'gemini-3.5-pro');
      });

      test('deserializes via sealed AgentConfig.fromJson', () {
        final json = {'type': 'antigravity', 'model': 'gemini-3.5-flash'};
        final config = AgentConfig.fromJson(json);
        expect(config, isA<AntigravityAgentConfig>());
        expect((config as AntigravityAgentConfig).model, 'gemini-3.5-flash');
      });
    });

    group('toJson', () {
      test('serializes all set fields with snake_case keys', () {
        const config = AntigravityAgentConfig(
          maxTotalTokens: '1000000',
          model: 'gemini-3.5-flash',
        );
        final json = config.toJson();
        expect(json['type'], 'antigravity');
        expect(json['max_total_tokens'], '1000000');
        expect(json['model'], 'gemini-3.5-flash');
      });

      test('omits null fields', () {
        const config = AntigravityAgentConfig();
        expect(config.toJson(), {'type': 'antigravity'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves all fields', () {
        final original = {
          'type': 'antigravity',
          'max_total_tokens': '1000000',
          'model': 'gemini-3.5-flash',
        };
        expect(AntigravityAgentConfig.fromJson(original).toJson(), original);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        const config = AntigravityAgentConfig(model: 'gemini-3.5-flash');
        final copy = config.copyWith(maxTotalTokens: '2000000');
        expect(copy.model, 'gemini-3.5-flash');
        expect(copy.maxTotalTokens, '2000000');
      });

      test('copies with null to clear fields', () {
        const config = AntigravityAgentConfig(
          maxTotalTokens: '1000000',
          model: 'gemini-3.5-flash',
        );
        final copy = config.copyWith(maxTotalTokens: null, model: null);
        expect(copy.maxTotalTokens, isNull);
        expect(copy.model, isNull);
      });
    });
  });

  group('CodeMenderAgentConfig', () {
    group('constructor', () {
      test('creates with all fields', () {
        const config = CodeMenderAgentConfig(
          findRequest: FindRequest(
            description: 'scan for issues',
            findingId: 'finding-1',
            mode: FindRequestMode.scan,
            sourceFiles: [FileContent(path: 'main.dart', content: 'void()')],
          ),
          fixRequest: FixRequest(
            description: 'fix issue',
            findingId: 'finding-1',
            sourceFiles: [FileContent(path: 'main.dart', content: 'void()')],
          ),
          model: 'gemini-3.5-pro',
          sessionConfig: SessionConfig(maxRounds: 5),
          sessionId: 'session-1',
        );
        expect(config.type, 'code-mender');
        expect(config.findRequest, isNotNull);
        expect(config.fixRequest, isNotNull);
        expect(config.model, 'gemini-3.5-pro');
        expect(config.sessionConfig, isNotNull);
        expect(config.sessionId, 'session-1');
      });

      test('creates with no fields', () {
        const config = CodeMenderAgentConfig();
        expect(config.findRequest, isNull);
        expect(config.fixRequest, isNull);
        expect(config.model, isNull);
        expect(config.sessionConfig, isNull);
        expect(config.sessionId, isNull);
      });
    });

    group('fromJson', () {
      test('deserializes nested find_request, fix_request, session_config', () {
        final json = {
          'type': 'code-mender',
          'find_request': {
            'description': 'scan',
            'finding_id': 'f-1',
            'mode': 'verify',
            'source_files': [
              {'path': 'a.dart', 'content': 'a'},
            ],
          },
          'fix_request': {
            'description': 'fix',
            'finding_id': 'f-1',
            'source_files': [
              {'path': 'a.dart', 'content': 'a'},
            ],
          },
          'session_config': {'max_rounds': 3},
          'session_id': 'sess-1',
        };
        final config = CodeMenderAgentConfig.fromJson(json);
        expect(config.findRequest!.description, 'scan');
        expect(config.findRequest!.findingId, 'f-1');
        expect(config.findRequest!.mode, FindRequestMode.verify);
        expect(config.findRequest!.sourceFiles, hasLength(1));
        expect(config.findRequest!.sourceFiles!.first.path, 'a.dart');
        expect(config.fixRequest!.description, 'fix');
        expect(config.fixRequest!.sourceFiles, hasLength(1));
        expect(config.sessionConfig!.maxRounds, 3);
        expect(config.sessionId, 'sess-1');
      });

      test('tolerates unrecognized mode value', () {
        final json = {
          'type': 'code-mender',
          'find_request': {'mode': 'future_mode'},
        };
        final config = CodeMenderAgentConfig.fromJson(json);
        expect(config.findRequest!.mode, isNull);
      });

      test('deserializes via sealed AgentConfig.fromJson', () {
        final json = {'type': 'code-mender', 'session_id': 'sess-1'};
        final config = AgentConfig.fromJson(json);
        expect(config, isA<CodeMenderAgentConfig>());
        expect((config as CodeMenderAgentConfig).sessionId, 'sess-1');
      });
    });

    group('toJson', () {
      test('serializes nested requests with snake_case keys', () {
        const config = CodeMenderAgentConfig(
          findRequest: FindRequest(mode: FindRequestMode.scan),
          fixRequest: FixRequest(findingId: 'f-1'),
          sessionConfig: SessionConfig(maxRounds: 2),
          sessionId: 'sess-1',
        );
        final json = config.toJson();
        expect(json['type'], 'code-mender');
        expect((json['find_request'] as Map)['mode'], 'scan');
        expect((json['fix_request'] as Map)['finding_id'], 'f-1');
        expect((json['session_config'] as Map)['max_rounds'], 2);
        expect(json['session_id'], 'sess-1');
      });

      test('omits null fields', () {
        const config = CodeMenderAgentConfig();
        expect(config.toJson(), {'type': 'code-mender'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves nested fields', () {
        final original = {
          'type': 'code-mender',
          'find_request': {
            'mode': 'verify',
            'source_files': [
              {'path': 'a.dart', 'content': 'a'},
            ],
          },
          'session_id': 'sess-1',
        };
        expect(CodeMenderAgentConfig.fromJson(original).toJson(), original);
      });
    });

    group('copyWith', () {
      test('copies with updated nested fields', () {
        const config = CodeMenderAgentConfig(sessionId: 'sess-1');
        final copy = config.copyWith(
          sessionConfig: const SessionConfig(maxRounds: 10),
        );
        expect(copy.sessionId, 'sess-1');
        expect(copy.sessionConfig!.maxRounds, 10);
      });

      test('copies with null to clear fields', () {
        const config = CodeMenderAgentConfig(sessionId: 'sess-1');
        final copy = config.copyWith(sessionId: null);
        expect(copy.sessionId, isNull);
      });
    });
  });

  group('AgentConfig unknown type fallback', () {
    test('unrecognized type still dispatches to DynamicAgentConfig', () {
      final json = {'type': 'some_future_agent', 'custom_field': 'value'};
      final config = AgentConfig.fromJson(json);
      expect(config, isA<DynamicAgentConfig>());
      final dynamicConfig = config as DynamicAgentConfig;
      expect(dynamicConfig.additionalProperties, {'custom_field': 'value'});
    });
  });
}
