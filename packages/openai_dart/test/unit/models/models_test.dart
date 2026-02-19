import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Model', () {
    test('fromJson parses full response correctly', () {
      final json = {
        'id': 'gpt-4o',
        'object': 'model',
        'created': 1699472000,
        'owned_by': 'openai',
      };

      final model = Model.fromJson(json);

      expect(model.id, 'gpt-4o');
      expect(model.object, 'model');
      expect(model.created, 1699472000);
      expect(model.ownedBy, 'openai');
      expect(model.createdAt, isA<DateTime>());
    });

    test('fromJson handles missing created (Cohere compatibility)', () {
      final json = {
        'id': 'command-r-plus',
        'object': 'model',
        // No 'created' field — Cohere doesn't return this
      };

      final model = Model.fromJson(json);

      expect(model.id, 'command-r-plus');
      expect(model.created, isNull);
      expect(model.createdAt, isNull);
    });

    test('fromJson handles missing owned_by', () {
      final json = {
        'id': 'some-model',
        'object': 'model',
        'created': 1699472000,
        // No 'owned_by' field
      };

      final model = Model.fromJson(json);

      expect(model.id, 'some-model');
      expect(model.ownedBy, isNull);
    });

    test('fromJson handles both created and owned_by missing', () {
      final json = {'id': 'command-r-plus', 'object': 'model'};

      final model = Model.fromJson(json);

      expect(model.id, 'command-r-plus');
      expect(model.created, isNull);
      expect(model.ownedBy, isNull);
      expect(model.createdAt, isNull);
    });

    test('toJson omits null fields', () {
      const model = Model(id: 'command-r-plus', object: 'model');

      final json = model.toJson();

      expect(json['id'], 'command-r-plus');
      expect(json['object'], 'model');
      expect(json.containsKey('created'), isFalse);
      expect(json.containsKey('owned_by'), isFalse);
    });

    test('toJson includes non-null fields', () {
      const model = Model(
        id: 'gpt-4o',
        object: 'model',
        created: 1699472000,
        ownedBy: 'openai',
      );

      final json = model.toJson();

      expect(json['created'], 1699472000);
      expect(json['owned_by'], 'openai');
    });

    test('toJson/fromJson round-trip with null fields', () {
      const original = Model(id: 'command-r-plus', object: 'model');

      final json = original.toJson();
      final restored = Model.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.object, original.object);
      expect(restored.created, isNull);
      expect(restored.ownedBy, isNull);
    });

    test('toJson/fromJson round-trip with all fields', () {
      const original = Model(
        id: 'gpt-4o',
        object: 'model',
        created: 1699472000,
        ownedBy: 'openai',
      );

      final json = original.toJson();
      final restored = Model.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.created, original.created);
      expect(restored.ownedBy, original.ownedBy);
    });
  });

  group('ModelList', () {
    test('fromJson parses minimal response (Cohere-style)', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'command-r-plus',
            'object': 'model',
            // No 'created' or 'owned_by'
          },
          {'id': 'command-r', 'object': 'model'},
        ],
      };

      final modelList = ModelList.fromJson(json);

      expect(modelList.data.length, 2);
      expect(modelList.data[0].id, 'command-r-plus');
      expect(modelList.data[0].created, isNull);
      expect(modelList.data[0].ownedBy, isNull);
      expect(modelList.data[1].id, 'command-r');
    });

    test('equality compares models not just length', () {
      const listA = ModelList(
        object: 'list',
        data: [
          Model(id: 'gpt-4o', object: 'model'),
          Model(id: 'gpt-3.5-turbo', object: 'model'),
        ],
      );

      const listB = ModelList(
        object: 'list',
        data: [
          Model(id: 'command-r-plus', object: 'model'),
          Model(id: 'command-r', object: 'model'),
        ],
      );

      // Same length but different models — should NOT be equal.
      expect(listA, isNot(equals(listB)));
    });

    test('equality returns true for same models', () {
      const listA = ModelList(
        object: 'list',
        data: [
          Model(id: 'gpt-4o', object: 'model'),
          Model(id: 'gpt-3.5-turbo', object: 'model'),
        ],
      );

      const listB = ModelList(
        object: 'list',
        data: [
          Model(id: 'gpt-4o', object: 'model'),
          Model(id: 'gpt-3.5-turbo', object: 'model'),
        ],
      );

      expect(listA, equals(listB));
    });

    test('ownedBy filters correctly with nullable field', () {
      final json = {
        'object': 'list',
        'data': [
          {
            'id': 'gpt-4o',
            'object': 'model',
            'created': 1699472000,
            'owned_by': 'openai',
          },
          {
            'id': 'command-r',
            'object': 'model',
            // No 'owned_by'
          },
        ],
      };

      final modelList = ModelList.fromJson(json);

      expect(modelList.ownedBy('openai').length, 1);
      expect(modelList.ownedBy('openai').first.id, 'gpt-4o');
    });
  });
}
