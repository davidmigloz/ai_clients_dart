import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CapabilitySupport', () {
    test('fromJson and toJson round-trip', () {
      final json = {'supported': true};
      final cap = CapabilitySupport.fromJson(json);

      expect(cap.supported, isTrue);
      expect(cap.toJson(), json);
    });

    test('equality works', () {
      const a = CapabilitySupport(supported: true);
      const b = CapabilitySupport(supported: true);
      const c = CapabilitySupport(supported: false);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('ModelCapabilities', () {
    Map<String, dynamic> fullCapabilitiesJson() => {
      'batch': {'supported': true},
      'citations': {'supported': true},
      'code_execution': {'supported': true},
      'context_management': {
        'clear_thinking_20251015': {'supported': true},
        'clear_tool_uses_20250919': {'supported': true},
        'compact_20260112': {'supported': true},
        'supported': true,
      },
      'effort': {
        'high': {'supported': true},
        'low': {'supported': true},
        'max': {'supported': true},
        'medium': {'supported': true},
        'xhigh': null,
        'supported': true,
      },
      'image_input': {'supported': true},
      'pdf_input': {'supported': true},
      'structured_outputs': {'supported': true},
      'thinking': {
        'supported': true,
        'types': {
          'adaptive': {'supported': true},
          'enabled': {'supported': true},
        },
      },
    };

    test('fromJson deserializes all fields', () {
      final json = fullCapabilitiesJson();
      final caps = ModelCapabilities.fromJson(json);

      expect(caps.batch.supported, isTrue);
      expect(caps.citations.supported, isTrue);
      expect(caps.codeExecution.supported, isTrue);
      expect(caps.contextManagement.supported, isTrue);
      expect(caps.contextManagement.clearThinking20251015?.supported, isTrue);
      expect(caps.contextManagement.clearToolUses20250919?.supported, isTrue);
      expect(caps.contextManagement.compact20260112?.supported, isTrue);
      expect(caps.effort.supported, isTrue);
      expect(caps.effort.high.supported, isTrue);
      expect(caps.effort.low.supported, isTrue);
      expect(caps.effort.max.supported, isTrue);
      expect(caps.effort.medium.supported, isTrue);
      expect(caps.effort.xhigh, isNull);
      expect(caps.imageInput.supported, isTrue);
      expect(caps.pdfInput.supported, isTrue);
      expect(caps.structuredOutputs.supported, isTrue);
      expect(caps.thinking.supported, isTrue);
      expect(caps.thinking.types.adaptive.supported, isTrue);
      expect(caps.thinking.types.enabled.supported, isTrue);
    });

    test('toJson round-trip works', () {
      final json = fullCapabilitiesJson();
      final caps = ModelCapabilities.fromJson(json);
      final roundTripped = ModelCapabilities.fromJson(caps.toJson());

      expect(roundTripped, equals(caps));
    });

    test('equality works', () {
      final json = fullCapabilitiesJson();
      final a = ModelCapabilities.fromJson(json);
      final b = ModelCapabilities.fromJson(json);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('EffortCapability round-trips xhigh when present', () {
      final json = fullCapabilitiesJson();
      (json['effort'] as Map<String, dynamic>)['xhigh'] = {'supported': true};

      final caps = ModelCapabilities.fromJson(json);
      expect(caps.effort.xhigh?.supported, isTrue);

      final roundTripped = ModelCapabilities.fromJson(caps.toJson());
      expect(roundTripped.effort.xhigh?.supported, isTrue);
    });

    test('EffortCapability always serializes xhigh key (null when absent)', () {
      final json = fullCapabilitiesJson();
      final caps = ModelCapabilities.fromJson(json);

      final effortJson = caps.effort.toJson();
      expect(effortJson.containsKey('xhigh'), isTrue);
      expect(effortJson['xhigh'], isNull);
    });
  });

  group('EffortLevel', () {
    test('xhigh round-trips', () {
      expect(EffortLevel.fromJson('xhigh'), EffortLevel.xhigh);
      expect(EffortLevel.xhigh.toJson(), 'xhigh');
    });
  });

  group('ContextManagementCapability', () {
    test('handles null strategy fields', () {
      final json = {
        'clear_thinking_20251015': null,
        'clear_tool_uses_20250919': null,
        'compact_20260112': {'supported': true},
        'supported': true,
      };

      final cap = ContextManagementCapability.fromJson(json);

      expect(cap.clearThinking20251015, isNull);
      expect(cap.clearToolUses20250919, isNull);
      expect(cap.compact20260112?.supported, isTrue);
      expect(cap.supported, isTrue);
    });
  });

  group('ModelInfo', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'id': 'claude-sonnet-4-6',
        'type': 'model',
        'display_name': 'Claude Sonnet 4',
        'created_at': '2025-05-14T00:00:00Z',
      };

      final model = ModelInfo.fromJson(json);

      expect(model.id, 'claude-sonnet-4-6');
      expect(model.type, 'model');
      expect(model.displayName, 'Claude Sonnet 4');
      expect(model.createdAt, DateTime.utc(2025, 5, 14));
      expect(model.capabilities, isNull);
      expect(model.maxInputTokens, isNull);
      expect(model.maxTokens, isNull);
    });

    test('fromJson deserializes with capabilities', () {
      final json = {
        'id': 'claude-sonnet-4-5-20250929',
        'type': 'model',
        'display_name': 'Claude Sonnet 4.5',
        'created_at': '2025-09-29T00:00:00Z',
        'capabilities': {
          'batch': {'supported': true},
          'citations': {'supported': true},
          'code_execution': {'supported': true},
          'context_management': {
            'clear_thinking_20251015': {'supported': true},
            'clear_tool_uses_20250919': {'supported': true},
            'compact_20260112': {'supported': true},
            'supported': true,
          },
          'effort': {
            'high': {'supported': true},
            'low': {'supported': true},
            'max': {'supported': false},
            'medium': {'supported': true},
            'supported': true,
          },
          'image_input': {'supported': true},
          'pdf_input': {'supported': true},
          'structured_outputs': {'supported': true},
          'thinking': {
            'supported': true,
            'types': {
              'adaptive': {'supported': true},
              'enabled': {'supported': true},
            },
          },
        },
        'max_input_tokens': 200000,
        'max_tokens': 16384,
      };

      final model = ModelInfo.fromJson(json);

      expect(model.id, 'claude-sonnet-4-5-20250929');
      expect(model.capabilities, isNotNull);
      expect(model.capabilities!.batch.supported, isTrue);
      expect(model.capabilities!.effort.max.supported, isFalse);
      expect(model.capabilities!.thinking.types.adaptive.supported, isTrue);
      expect(model.maxInputTokens, 200000);
      expect(model.maxTokens, 16384);
    });

    test('toJson serializes correctly', () {
      final model = ModelInfo(
        id: 'claude-3-opus-20240229',
        displayName: 'Claude 3 Opus',
        createdAt: DateTime.utc(2024, 2, 29),
      );

      final json = model.toJson();

      expect(json['id'], 'claude-3-opus-20240229');
      expect(json['type'], 'model');
      expect(json['display_name'], 'Claude 3 Opus');
      expect(json['created_at'], '2024-02-29T00:00:00.000Z');
      expect(json.containsKey('capabilities'), isFalse);
      expect(json.containsKey('max_input_tokens'), isFalse);
      expect(json.containsKey('max_tokens'), isFalse);
    });

    test('toJson includes maxInputTokens and maxTokens when present', () {
      final model = ModelInfo(
        id: 'test',
        displayName: 'Test',
        createdAt: DateTime.utc(2024),
        maxInputTokens: 100000,
        maxTokens: 8192,
      );

      final json = model.toJson();

      expect(json['max_input_tokens'], 100000);
      expect(json['max_tokens'], 8192);
    });

    test('round-trip serialization works', () {
      final original = ModelInfo(
        id: 'claude-3-haiku-20240307',
        displayName: 'Claude 3 Haiku',
        createdAt: DateTime.utc(2024, 3, 7),
      );

      final json = original.toJson();
      final restored = ModelInfo.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.displayName, original.displayName);
      expect(restored.createdAt, original.createdAt);
    });

    test('equality works correctly', () {
      final model1 = ModelInfo(
        id: 'test-model',
        displayName: 'Test Model',
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final model2 = ModelInfo(
        id: 'test-model',
        displayName: 'Test Model',
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final model3 = ModelInfo(
        id: 'other-model',
        displayName: 'Other Model',
        createdAt: DateTime.utc(2024, 1, 1),
      );

      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });

    test('equality considers new fields', () {
      final model1 = ModelInfo(
        id: 'test',
        displayName: 'Test',
        createdAt: DateTime.utc(2024),
        maxInputTokens: 100000,
      );
      final model2 = ModelInfo(
        id: 'test',
        displayName: 'Test',
        createdAt: DateTime.utc(2024),
        maxInputTokens: 200000,
      );

      expect(model1, isNot(equals(model2)));
    });

    test('copyWith can set and clear new fields', () {
      final original = ModelInfo(
        id: 'test',
        displayName: 'Test',
        createdAt: DateTime.utc(2024),
        maxInputTokens: 100000,
      );

      final modified = original.copyWith(maxInputTokens: null, maxTokens: 8192);

      expect(modified.maxInputTokens, isNull);
      expect(modified.maxTokens, 8192);
    });
  });

  group('ModelListResponse', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'data': [
          {
            'id': 'claude-sonnet-4-6',
            'type': 'model',
            'display_name': 'Claude Sonnet 4',
            'created_at': '2025-05-14T00:00:00Z',
          },
        ],
        'has_more': true,
        'first_id': 'claude-sonnet-4-6',
        'last_id': 'claude-sonnet-4-6',
      };

      final response = ModelListResponse.fromJson(json);

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'claude-sonnet-4-6');
      expect(response.data.first.displayName, 'Claude Sonnet 4');
      expect(response.hasMore, isTrue);
      expect(response.firstId, 'claude-sonnet-4-6');
      expect(response.lastId, 'claude-sonnet-4-6');
    });

    test('fromJson deserializes with required fields only', () {
      final json = {'data': <Map<String, dynamic>>[], 'has_more': false};

      final response = ModelListResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.hasMore, isFalse);
      expect(response.firstId, isNull);
      expect(response.lastId, isNull);
    });

    test('fromJson deserializes with multiple models', () {
      final json = {
        'data': [
          {
            'id': 'claude-sonnet-4-6',
            'type': 'model',
            'display_name': 'Claude Sonnet 4',
            'created_at': '2025-05-14T00:00:00Z',
          },
          {
            'id': 'claude-3-5-haiku-20241022',
            'type': 'model',
            'display_name': 'Claude 3.5 Haiku',
            'created_at': '2024-10-22T00:00:00Z',
          },
          {
            'id': 'claude-3-haiku-20240307',
            'type': 'model',
            'display_name': 'Claude 3 Haiku',
            'created_at': '2024-03-07T00:00:00Z',
          },
        ],
        'has_more': true,
        'first_id': 'claude-sonnet-4-6',
        'last_id': 'claude-3-haiku-20240307',
      };

      final response = ModelListResponse.fromJson(json);

      expect(response.data, hasLength(3));
      expect(response.data[0].id, 'claude-sonnet-4-6');
      expect(response.data[1].id, 'claude-3-5-haiku-20241022');
      expect(response.data[2].id, 'claude-3-haiku-20240307');
      expect(response.firstId, 'claude-sonnet-4-6');
      expect(response.lastId, 'claude-3-haiku-20240307');
    });

    test('toJson serializes correctly', () {
      final response = ModelListResponse(
        data: [
          ModelInfo(
            id: 'claude-sonnet-4-6',
            displayName: 'Claude Sonnet 4',
            createdAt: DateTime.utc(2025, 5, 14),
          ),
        ],
        hasMore: false,
        firstId: 'claude-sonnet-4-6',
        lastId: 'claude-sonnet-4-6',
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      final dataList = json['data'] as List<dynamic>;
      expect(
        (dataList.first as Map<String, dynamic>)['id'],
        'claude-sonnet-4-6',
      );
      expect(json['has_more'], false);
      expect(json['first_id'], 'claude-sonnet-4-6');
      expect(json['last_id'], 'claude-sonnet-4-6');
    });

    test('toJson excludes null optional fields', () {
      const response = ModelListResponse(data: [], hasMore: false);

      final json = response.toJson();

      expect(json.containsKey('first_id'), isFalse);
      expect(json.containsKey('last_id'), isFalse);
    });

    test('round-trip serialization works', () {
      final original = ModelListResponse(
        data: [
          ModelInfo(
            id: 'claude-3-opus-20240229',
            displayName: 'Claude 3 Opus',
            createdAt: DateTime.utc(2024, 2, 29),
          ),
        ],
        hasMore: true,
        firstId: 'claude-3-opus-20240229',
        lastId: 'claude-3-opus-20240229',
      );

      final json = original.toJson();
      final restored = ModelListResponse.fromJson(json);

      expect(restored.data, hasLength(1));
      expect(restored.data.first.id, original.data.first.id);
      expect(restored.data.first.displayName, original.data.first.displayName);
      expect(restored.hasMore, original.hasMore);
      expect(restored.firstId, original.firstId);
      expect(restored.lastId, original.lastId);
    });
  });
}
