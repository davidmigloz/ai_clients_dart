import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ModelInfo', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'id': 'claude-sonnet-4-20250514',
        'type': 'model',
        'display_name': 'Claude Sonnet 4',
        'created_at': '2025-05-14T00:00:00Z',
      };

      final model = ModelInfo.fromJson(json);

      expect(model.id, 'claude-sonnet-4-20250514');
      expect(model.type, 'model');
      expect(model.displayName, 'Claude Sonnet 4');
      expect(model.createdAt, DateTime.utc(2025, 5, 14));
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
  });

  group('ModelListResponse', () {
    test('fromJson deserializes with all fields', () {
      final json = {
        'data': [
          {
            'id': 'claude-sonnet-4-20250514',
            'type': 'model',
            'display_name': 'Claude Sonnet 4',
            'created_at': '2025-05-14T00:00:00Z',
          },
        ],
        'has_more': true,
        'first_id': 'claude-sonnet-4-20250514',
        'last_id': 'claude-sonnet-4-20250514',
      };

      final response = ModelListResponse.fromJson(json);

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'claude-sonnet-4-20250514');
      expect(response.data.first.displayName, 'Claude Sonnet 4');
      expect(response.hasMore, isTrue);
      expect(response.firstId, 'claude-sonnet-4-20250514');
      expect(response.lastId, 'claude-sonnet-4-20250514');
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
            'id': 'claude-sonnet-4-20250514',
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
        'first_id': 'claude-sonnet-4-20250514',
        'last_id': 'claude-3-haiku-20240307',
      };

      final response = ModelListResponse.fromJson(json);

      expect(response.data, hasLength(3));
      expect(response.data[0].id, 'claude-sonnet-4-20250514');
      expect(response.data[1].id, 'claude-3-5-haiku-20241022');
      expect(response.data[2].id, 'claude-3-haiku-20240307');
      expect(response.firstId, 'claude-sonnet-4-20250514');
      expect(response.lastId, 'claude-3-haiku-20240307');
    });

    test('toJson serializes correctly', () {
      final response = ModelListResponse(
        data: [
          ModelInfo(
            id: 'claude-sonnet-4-20250514',
            displayName: 'Claude Sonnet 4',
            createdAt: DateTime.utc(2025, 5, 14),
          ),
        ],
        hasMore: false,
        firstId: 'claude-sonnet-4-20250514',
        lastId: 'claude-sonnet-4-20250514',
      );

      final json = response.toJson();

      expect(json['data'], hasLength(1));
      final dataList = json['data'] as List<dynamic>;
      expect(
        (dataList.first as Map<String, dynamic>)['id'],
        'claude-sonnet-4-20250514',
      );
      expect(json['has_more'], false);
      expect(json['first_id'], 'claude-sonnet-4-20250514');
      expect(json['last_id'], 'claude-sonnet-4-20250514');
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
