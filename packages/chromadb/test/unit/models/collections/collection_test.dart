import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('Collection', () {
    test('fromJson creates collection with all fields', () {
      final json = {
        'id': 'coll-123',
        'name': 'my-collection',
        'metadata': {'key': 'value'},
        'tenant': 'my-tenant',
        'database': 'my-database',
        'log_position': 42,
        'version': 1,
        'configuration_json': {
          'hnsw': {'space': 'cosine', 'ef_construction': 100},
          'embedding_function': {'name': 'default'},
        },
        'dimension': 384,
        'schema': {
          'defaults': {'string': 'text'},
          'keys': {'title': 'text'},
        },
      };

      final collection = Collection.fromJson(json);

      expect(collection.id, 'coll-123');
      expect(collection.name, 'my-collection');
      expect(collection.metadata, {'key': 'value'});
      expect(collection.tenant, 'my-tenant');
      expect(collection.database, 'my-database');
      expect(collection.logPosition, 42);
      expect(collection.version, 1);
      expect(collection.configurationJson.hnsw, {
        'space': 'cosine',
        'ef_construction': 100,
      });
      expect(collection.configurationJson.embeddingFunction, {
        'name': 'default',
      });
      expect(collection.dimension, 384);
      expect(collection.schema, isNotNull);
      expect(collection.schema!.defaults, {'string': 'text'});
      expect(collection.schema!.keys, {'title': 'text'});
    });

    test('fromJson handles minimal required fields', () {
      final json = {
        'id': 'coll-456',
        'name': 'minimal-collection',
        'tenant': 'default_tenant',
        'database': 'default_database',
        'log_position': 0,
        'version': 0,
        'configuration_json': <String, dynamic>{},
      };

      final collection = Collection.fromJson(json);

      expect(collection.id, 'coll-456');
      expect(collection.name, 'minimal-collection');
      expect(collection.metadata, isNull);
      expect(collection.tenant, 'default_tenant');
      expect(collection.database, 'default_database');
      expect(collection.logPosition, 0);
      expect(collection.version, 0);
      expect(collection.configurationJson, isNotNull);
      expect(collection.dimension, isNull);
      expect(collection.schema, isNull);
    });

    test('toJson converts collection correctly', () {
      const collection = Collection(
        id: 'coll-789',
        name: 'export-collection',
        metadata: {'foo': 'bar'},
        tenant: 'export-tenant',
        database: 'export-database',
        logPosition: 100,
        version: 2,
        configurationJson: CollectionConfiguration(hnsw: {'space': 'l2'}),
        dimension: 512,
        schema: CollectionSchema(defaults: {'string': 'text'}, keys: {}),
      );

      final json = collection.toJson();

      expect(json['id'], 'coll-789');
      expect(json['name'], 'export-collection');
      expect(json['metadata'], {'foo': 'bar'});
      expect(json['tenant'], 'export-tenant');
      expect(json['database'], 'export-database');
      expect(json['log_position'], 100);
      expect(json['version'], 2);
      expect(json['configuration_json'], {
        'hnsw': {'space': 'l2'},
      });
      expect(json['dimension'], 512);
      expect(json['schema'], <String, dynamic>{
        'defaults': {'string': 'text'},
        'keys': <String, dynamic>{},
      });
    });

    test('toJson excludes null optional values', () {
      const collection = Collection(
        id: 'coll-only',
        name: 'minimal',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );

      final json = collection.toJson();

      expect(json['id'], 'coll-only');
      expect(json['name'], 'minimal');
      expect(json.containsKey('metadata'), isFalse);
      expect(json['tenant'], 'default_tenant');
      expect(json['database'], 'default_database');
      expect(json['log_position'], 0);
      expect(json['version'], 0);
      expect(json.containsKey('configuration_json'), isTrue);
      expect(json.containsKey('dimension'), isFalse);
      expect(json.containsKey('schema'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = Collection(
        id: 'original-id',
        name: 'original-name',
        metadata: {'original': 'data'},
        tenant: 'original-tenant',
        database: 'original-database',
        logPosition: 50,
        version: 3,
        configurationJson: CollectionConfiguration(),
      );

      final copied = original.copyWith();

      expect(copied.id, 'original-id');
      expect(copied.name, 'original-name');
      expect(copied.metadata, {'original': 'data'});
      expect(copied.tenant, 'original-tenant');
      expect(copied.database, 'original-database');
      expect(copied.logPosition, 50);
      expect(copied.version, 3);
    });

    test('copyWith updates specified values', () {
      const original = Collection(
        id: 'original-id',
        name: 'original-name',
        metadata: {'original': 'data'},
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );

      final copied = original.copyWith(
        name: 'new-name',
        metadata: {'new': 'metadata'},
      );

      expect(copied.id, 'original-id');
      expect(copied.name, 'new-name');
      expect(copied.metadata, {'new': 'metadata'});
    });

    test('equality works correctly', () {
      const coll1 = Collection(
        id: 'id',
        name: 'coll',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );
      const coll2 = Collection(
        id: 'id',
        name: 'coll',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );
      const coll3 = Collection(
        id: 'other',
        name: 'coll',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );

      expect(coll1, equals(coll2));
      expect(coll1, isNot(equals(coll3)));
    });

    test('hashCode is consistent with equality', () {
      const coll1 = Collection(
        id: 'id',
        name: 'coll',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );
      const coll2 = Collection(
        id: 'id',
        name: 'coll',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );

      expect(coll1.hashCode, equals(coll2.hashCode));
    });

    test('toString returns readable representation', () {
      const collection = Collection(
        id: 'coll-123',
        name: 'my-coll',
        tenant: 'default_tenant',
        database: 'default_database',
        logPosition: 0,
        version: 0,
        configurationJson: CollectionConfiguration(),
      );

      expect(collection.toString(), contains('Collection'));
      expect(collection.toString(), contains('coll-123'));
      expect(collection.toString(), contains('my-coll'));
    });
  });

  group('CreateCollectionRequest', () {
    test('toJson converts request with all fields', () {
      const request = CreateCollectionRequest(
        name: 'new-collection',
        metadata: {'description': 'test'},
        getOrCreate: true,
      );

      final json = request.toJson();

      expect(json['name'], 'new-collection');
      expect(json['metadata'], {'description': 'test'});
      expect(json['get_or_create'], true);
    });

    test('toJson excludes null values', () {
      const request = CreateCollectionRequest(name: 'minimal');

      final json = request.toJson();

      expect(json['name'], 'minimal');
      expect(json.containsKey('metadata'), isFalse);
      expect(json.containsKey('get_or_create'), isFalse);
    });

    test('copyWith preserves values when not specified', () {
      const original = CreateCollectionRequest(
        name: 'original-collection',
        metadata: {'key': 'value'},
        getOrCreate: true,
      );

      final copy = original.copyWith();

      expect(copy.name, 'original-collection');
      expect(copy.metadata, {'key': 'value'});
      expect(copy.getOrCreate, true);
    });

    test('copyWith can set fields to null', () {
      const original = CreateCollectionRequest(
        name: 'collection',
        metadata: {'key': 'value'},
        getOrCreate: true,
      );

      final copy = original.copyWith(metadata: null, getOrCreate: null);

      expect(copy.name, 'collection');
      expect(copy.metadata, isNull);
      expect(copy.getOrCreate, isNull);
    });

    test('equality works correctly', () {
      const request1 = CreateCollectionRequest(
        name: 'coll',
        metadata: {'key': 'value'},
      );
      const request2 = CreateCollectionRequest(
        name: 'coll',
        metadata: {'key': 'value'},
      );
      const request3 = CreateCollectionRequest(
        name: 'other',
        metadata: {'key': 'value'},
      );

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });

    test('hashCode is consistent with equality', () {
      const request1 = CreateCollectionRequest(
        name: 'coll',
        metadata: {'key': 'value'},
      );
      const request2 = CreateCollectionRequest(
        name: 'coll',
        metadata: {'key': 'value'},
      );

      expect(request1.hashCode, equals(request2.hashCode));
    });

    test('toString returns readable representation', () {
      const request = CreateCollectionRequest(name: 'my-coll');

      expect(request.toString(), contains('CreateCollectionRequest'));
      expect(request.toString(), contains('my-coll'));
    });
  });

  group('UpdateCollectionRequest', () {
    test('toJson converts request with all fields', () {
      const request = UpdateCollectionRequest(
        newName: 'renamed-collection',
        newMetadata: {'updated': 'true'},
      );

      final json = request.toJson();

      expect(json['new_name'], 'renamed-collection');
      expect(json['new_metadata'], {'updated': 'true'});
    });

    test('toJson excludes null values', () {
      const request = UpdateCollectionRequest();

      final json = request.toJson();

      expect(json.isEmpty, isTrue);
    });

    test('copyWith preserves values when not specified', () {
      const original = UpdateCollectionRequest(
        newName: 'renamed',
        newMetadata: {'key': 'value'},
      );

      final copy = original.copyWith();

      expect(copy.newName, 'renamed');
      expect(copy.newMetadata, {'key': 'value'});
    });

    test('copyWith can set fields to null', () {
      const original = UpdateCollectionRequest(
        newName: 'renamed',
        newMetadata: {'key': 'value'},
      );

      final copy = original.copyWith(newName: null, newMetadata: null);

      expect(copy.newName, isNull);
      expect(copy.newMetadata, isNull);
    });

    test('equality works correctly', () {
      const request1 = UpdateCollectionRequest(newName: 'new');
      const request2 = UpdateCollectionRequest(newName: 'new');
      const request3 = UpdateCollectionRequest(newName: 'other');

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });

    test('hashCode is consistent with equality', () {
      const request1 = UpdateCollectionRequest(newName: 'new');
      const request2 = UpdateCollectionRequest(newName: 'new');

      expect(request1.hashCode, equals(request2.hashCode));
    });

    test('toString returns readable representation', () {
      const request = UpdateCollectionRequest(newName: 'renamed-coll');

      expect(request.toString(), contains('UpdateCollectionRequest'));
      expect(request.toString(), contains('renamed-coll'));
    });
  });

  group('CollectionConfiguration', () {
    test('fromJson creates configuration with all fields', () {
      final json = {
        'hnsw': {'space': 'cosine', 'ef_construction': 200},
        'spann': {'num_clusters': 64},
        'embedding_function': {
          'name': 'openai',
          'model': 'text-embedding-3-small',
        },
      };

      final config = CollectionConfiguration.fromJson(json);

      expect(config.hnsw, {'space': 'cosine', 'ef_construction': 200});
      expect(config.spann, {'num_clusters': 64});
      expect(config.embeddingFunction, {
        'name': 'openai',
        'model': 'text-embedding-3-small',
      });
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};

      final config = CollectionConfiguration.fromJson(json);

      expect(config.hnsw, isNull);
      expect(config.spann, isNull);
      expect(config.embeddingFunction, isNull);
    });

    test('toJson converts configuration correctly', () {
      const config = CollectionConfiguration(
        hnsw: {'space': 'l2'},
        embeddingFunction: {'name': 'default'},
      );

      final json = config.toJson();

      expect(json['hnsw'], {'space': 'l2'});
      expect(json['embedding_function'], {'name': 'default'});
      expect(json.containsKey('spann'), isFalse);
    });

    test('equality works correctly', () {
      const config1 = CollectionConfiguration(hnsw: {'space': 'cosine'});
      const config2 = CollectionConfiguration(hnsw: {'space': 'cosine'});
      const config3 = CollectionConfiguration(hnsw: {'space': 'l2'});

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('hashCode is consistent with equality', () {
      const config1 = CollectionConfiguration(hnsw: {'space': 'cosine'});
      const config2 = CollectionConfiguration(hnsw: {'space': 'cosine'});

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('toString returns readable representation', () {
      const config = CollectionConfiguration(hnsw: {'space': 'cosine'});

      expect(config.toString(), contains('CollectionConfiguration'));
    });
  });

  group('ForkCountResponse', () {
    test('fromJson creates response with count', () {
      final json = {'count': 5};
      final response = ForkCountResponse.fromJson(json);
      expect(response.count, 5);
    });

    test('fromJson handles zero count', () {
      final json = {'count': 0};
      final response = ForkCountResponse.fromJson(json);
      expect(response.count, 0);
    });

    test('toJson converts response correctly', () {
      const response = ForkCountResponse(count: 3);
      final json = response.toJson();
      expect(json, {'count': 3});
    });

    test('copyWith replaces count', () {
      const original = ForkCountResponse(count: 5);
      final copy = original.copyWith(count: 10);
      expect(copy.count, 10);
    });

    test('copyWith preserves count when not specified', () {
      const original = ForkCountResponse(count: 5);
      final copy = original.copyWith();
      expect(copy.count, 5);
    });

    test('equality works correctly', () {
      const r1 = ForkCountResponse(count: 5);
      const r2 = ForkCountResponse(count: 5);
      const r3 = ForkCountResponse(count: 3);
      expect(r1, equals(r2));
      expect(r1, isNot(equals(r3)));
    });

    test('hashCode is consistent with equality', () {
      const r1 = ForkCountResponse(count: 5);
      const r2 = ForkCountResponse(count: 5);
      expect(r1.hashCode, equals(r2.hashCode));
    });

    test('toString returns readable representation', () {
      const response = ForkCountResponse(count: 7);
      expect(response.toString(), contains('ForkCountResponse'));
      expect(response.toString(), contains('7'));
    });
  });

  group('CollectionSchema', () {
    test('fromJson creates schema with all fields', () {
      final json = {
        'defaults': {'string': 'text', 'number': 'numeric'},
        'keys': {'title': 'text', 'score': 'numeric'},
        'cmek': {'key_id': 'kms-key-123'},
        'source_attached_function_id': 'func-456',
      };

      final schema = CollectionSchema.fromJson(json);

      expect(schema.defaults, {'string': 'text', 'number': 'numeric'});
      expect(schema.keys, {'title': 'text', 'score': 'numeric'});
      expect(schema.cmek, {'key_id': 'kms-key-123'});
      expect(schema.sourceAttachedFunctionId, 'func-456');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'defaults': {'string': 'text'},
        'keys': <String, dynamic>{},
      };

      final schema = CollectionSchema.fromJson(json);

      expect(schema.defaults, {'string': 'text'});
      expect(schema.keys, <String, dynamic>{});
      expect(schema.cmek, isNull);
      expect(schema.sourceAttachedFunctionId, isNull);
    });

    test('fromJson provides empty maps for missing required fields', () {
      final json = <String, dynamic>{};

      final schema = CollectionSchema.fromJson(json);

      expect(schema.defaults, <String, dynamic>{});
      expect(schema.keys, <String, dynamic>{});
    });

    test('toJson converts schema correctly', () {
      const schema = CollectionSchema(
        defaults: {'string': 'text'},
        keys: {'title': 'text'},
        cmek: {'key': 'value'},
        sourceAttachedFunctionId: 'func-123',
      );

      final json = schema.toJson();

      expect(json['defaults'], {'string': 'text'});
      expect(json['keys'], {'title': 'text'});
      expect(json['cmek'], {'key': 'value'});
      expect(json['source_attached_function_id'], 'func-123');
    });

    test('toJson excludes null optional fields', () {
      const schema = CollectionSchema(defaults: {'string': 'text'}, keys: {});

      final json = schema.toJson();

      expect(json.containsKey('cmek'), isFalse);
      expect(json.containsKey('source_attached_function_id'), isFalse);
    });

    test('equality works correctly', () {
      const schema1 = CollectionSchema(defaults: {'k': 'v'}, keys: {});
      const schema2 = CollectionSchema(defaults: {'k': 'v'}, keys: {});
      const schema3 = CollectionSchema(defaults: {'k': 'other'}, keys: {});

      expect(schema1, equals(schema2));
      expect(schema1, isNot(equals(schema3)));
    });

    test('hashCode is consistent with equality', () {
      const schema1 = CollectionSchema(defaults: {'k': 'v'}, keys: {});
      const schema2 = CollectionSchema(defaults: {'k': 'v'}, keys: {});

      expect(schema1.hashCode, equals(schema2.hashCode));
    });

    test('toString returns readable representation', () {
      const schema = CollectionSchema(defaults: {}, keys: {});

      expect(schema.toString(), contains('CollectionSchema'));
    });
  });
}
