@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RegisterVespaSchemaFieldRequest model', () {
    final json = {
      'name': 'field-1',
      'type': 'embedding',
      'storage': 'in_memory',
      'ranking': 'embedding',
      'index_type': 'ann',
      'multidimensional': false,
    };

    test('round-trips through JSON', () {
      final field = RegisterVespaSchemaFieldRequest.fromJson(json);
      expect(field.name, 'field-1');
      expect(field.type, SchemaFieldDataType.embedding);
      expect(field.storage, SchemaFieldStorage.inMemory);
      expect(field.ranking, SchemaFieldRankingType.embedding);
      expect(field.indexType, SchemaFieldIndex.ann);
      expect(field.multidimensional, isFalse);
      expect(field.toJson(), json);
    });

    test('handles null index_type', () {
      final field = RegisterVespaSchemaFieldRequest.fromJson({
        ...json,
        'index_type': null,
      });
      expect(field.indexType, isNull);
      expect(field.toJson()['index_type'], isNull);
    });

    test('copyWith and equality are value-based', () {
      final field = RegisterVespaSchemaFieldRequest.fromJson(json);
      expect(field, RegisterVespaSchemaFieldRequest.fromJson(json));
      expect(
        field.hashCode,
        RegisterVespaSchemaFieldRequest.fromJson(json).hashCode,
      );
      expect(field.copyWith(name: 'field-2').name, 'field-2');
      expect(field.copyWith(indexType: null).indexType, isNull);
      expect(field.toString(), contains('field-1'));
    });
  });

  group('RegisterVespaSchemaRequest model', () {
    final fieldJson = {
      'name': 'field-1',
      'type': 'string',
      'storage': 'on_disk',
      'ranking': 'text',
      'index_type': 'bm25',
      'multidimensional': false,
    };
    final json = {
      'name': 'schema-1',
      'fields': [fieldJson],
      'sd': 'schema schema-1 { ... }',
    };

    test('round-trips through JSON', () {
      final schema = RegisterVespaSchemaRequest.fromJson(json);
      expect(schema.name, 'schema-1');
      expect(schema.fields.single.type, SchemaFieldDataType.stringType);
      expect(schema.sd, 'schema schema-1 { ... }');
      expect(schema.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final schema = RegisterVespaSchemaRequest.fromJson(json);
      expect(schema, RegisterVespaSchemaRequest.fromJson(json));
      expect(schema.copyWith(name: 'schema-2').name, 'schema-2');
      expect(schema.toString(), contains('schema-1'));
    });
  });

  group('RegisterVespaIndexRequest model', () {
    final json = {
      'type': 'vespa',
      'k8s_cluster': 'cluster',
      'k8s_namespace': 'namespace',
      'vespa_instance_name': 'instance',
      'vespa_version': '8.0.0',
      'schemas': <Map<String, dynamic>>[],
      'query_url': 'https://vespa.example.com',
    };

    test('round-trips through JSON and defaults type to vespa', () {
      final index = RegisterVespaIndexRequest.fromJson(json);
      expect(index.type, 'vespa');
      expect(index.k8sCluster, 'cluster');
      expect(index.vespaVersion, '8.0.0');
      expect(index.queryUrl, 'https://vespa.example.com');
      expect(index.toJson(), json);

      final withoutType = Map<String, dynamic>.from(json)..remove('type');
      expect(RegisterVespaIndexRequest.fromJson(withoutType).type, 'vespa');
    });

    test('copyWith and equality are value-based', () {
      final index = RegisterVespaIndexRequest.fromJson(json);
      expect(index, RegisterVespaIndexRequest.fromJson(json));
      expect(index.copyWith(k8sCluster: 'other').k8sCluster, 'other');
      expect(index.toString(), contains('cluster'));
    });
  });

  group('RegisterSearchIndexRequest model', () {
    final indexJson = {
      'type': 'vespa',
      'k8s_cluster': 'cluster',
      'k8s_namespace': 'namespace',
      'vespa_instance_name': 'instance',
      'vespa_version': '8.0.0',
      'schemas': <Map<String, dynamic>>[],
      'query_url': 'https://vespa.example.com',
    };

    test('defaults status to offline', () {
      const request = RegisterSearchIndexRequest(
        name: 'My index',
        index: RegisterVespaIndexRequest(
          k8sCluster: 'cluster',
          k8sNamespace: 'namespace',
          vespaInstanceName: 'instance',
          vespaVersion: '8.0.0',
          queryUrl: 'https://vespa.example.com',
          schemas: [],
        ),
      );
      expect(request.status, SearchIndexStatus.offline);
      expect(request.toJson()['status'], 'offline');
    });

    test('round-trips through JSON with explicit status', () {
      final json = {'name': 'My index', 'status': 'online', 'index': indexJson};
      final request = RegisterSearchIndexRequest.fromJson(json);
      expect(request.name, 'My index');
      expect(request.status, SearchIndexStatus.online);
      expect(request.index.k8sCluster, 'cluster');
      expect(request.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final json = {'name': 'My index', 'status': 'online', 'index': indexJson};
      final request = RegisterSearchIndexRequest.fromJson(json);
      expect(request, RegisterSearchIndexRequest.fromJson(json));
      expect(request.copyWith(name: 'Renamed').name, 'Renamed');
      expect(request.toString(), contains('My index'));
    });
  });

  group('RegisterSearchIndexResponse model', () {
    test('round-trips through JSON', () {
      final response = RegisterSearchIndexResponse.fromJson(const {
        'id': 'idx-1',
      });
      expect(response.id, 'idx-1');
      expect(response.toJson(), {'id': 'idx-1'});
      expect(
        response,
        RegisterSearchIndexResponse.fromJson(const {'id': 'idx-1'}),
      );
      expect(response.copyWith(id: 'idx-2').id, 'idx-2');
      expect(response.toString(), contains('idx-1'));
    });
  });

  group('SearchIndexDetailSchema model', () {
    final json = {
      'name': 'schema-1',
      'id': 'schema-uuid',
      'document_count': 5,
      'last_modified': '2024-01-02T00:00:00.000Z',
      'latency_p95_s_threshold': 0.5,
    };

    test('round-trips through JSON', () {
      final schema = SearchIndexDetailSchema.fromJson(json);
      expect(schema.name, 'schema-1');
      expect(schema.documentCount, 5);
      expect(schema.lastModified, DateTime.utc(2024, 1, 2));
      expect(schema.latencyP95SThreshold, 0.5);
      expect(schema.toJson(), json);
    });

    test('handles null document_count and latency threshold', () {
      final schema = SearchIndexDetailSchema.fromJson({
        ...json,
        'document_count': null,
        'latency_p95_s_threshold': null,
      });
      expect(schema.documentCount, isNull);
      expect(schema.latencyP95SThreshold, isNull);
    });

    test('copyWith and equality are value-based', () {
      final schema = SearchIndexDetailSchema.fromJson(json);
      expect(schema, SearchIndexDetailSchema.fromJson(json));
      expect(schema.copyWith(documentCount: null).documentCount, isNull);
      expect(schema.toString(), contains('schema-1'));
    });
  });

  group('SearchIndexDetail model', () {
    final schemaJson = {
      'name': 'schema-1',
      'id': 'schema-uuid',
      'document_count': 5,
      'last_modified': '2024-01-02T00:00:00.000Z',
      'latency_p95_s_threshold': null,
    };
    final json = {
      'name': 'My index',
      'creator_id': 'user-1',
      'document_count': 5,
      'status': 'online',
      'created_at': '2024-01-01T00:00:00.000Z',
      'modified_at': '2024-01-02T00:00:00.000Z',
      'vespa_version': '8.0.0',
      'schemas': [schemaJson],
    };

    test('round-trips through JSON', () {
      final detail = SearchIndexDetail.fromJson(json);
      expect(detail.name, 'My index');
      expect(detail.status, SearchIndexStatus.online);
      expect(detail.vespaVersion, '8.0.0');
      expect(detail.schemas.single.name, 'schema-1');
      expect(detail.toJson(), json);
    });

    test('handles null vespa_version', () {
      final detail = SearchIndexDetail.fromJson({
        ...json,
        'vespa_version': null,
      });
      expect(detail.vespaVersion, isNull);
    });

    test('copyWith and equality are value-based', () {
      final detail = SearchIndexDetail.fromJson(json);
      expect(detail, SearchIndexDetail.fromJson(json));
      expect(detail.copyWith(name: 'Renamed').name, 'Renamed');
      expect(detail.toString(), contains('My index'));
    });
  });

  group('SearchIndexSchemaField model', () {
    final json = {
      'name': 'field-1',
      'type': 'bool',
      'storage': 'on_disk',
      'index_type': 'attribute',
    };

    test('round-trips through JSON', () {
      final field = SearchIndexSchemaField.fromJson(json);
      expect(field.type, SchemaFieldDataType.boolType);
      expect(field.storage, SchemaFieldStorage.onDisk);
      expect(field.indexType, SchemaFieldIndex.attribute);
      expect(field.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final field = SearchIndexSchemaField.fromJson(json);
      expect(field, SearchIndexSchemaField.fromJson(json));
      expect(field.copyWith(indexType: null).indexType, isNull);
      expect(field.toString(), contains('field-1'));
    });
  });

  group('SearchIndexSchemaDetail model', () {
    final fieldJson = {
      'name': 'field-1',
      'type': 'long',
      'storage': 'in_memory',
      'index_type': null,
    };
    final json = {
      'name': 'schema-1',
      'embedding_dimensions': 1536,
      'fields': [fieldJson],
    };

    test('round-trips through JSON', () {
      final detail = SearchIndexSchemaDetail.fromJson(json);
      expect(detail.name, 'schema-1');
      expect(detail.embeddingDimensions, 1536);
      expect(detail.fields.single.type, SchemaFieldDataType.long);
      expect(detail.toJson(), json);
    });

    test('handles null embedding_dimensions', () {
      final detail = SearchIndexSchemaDetail.fromJson({
        ...json,
        'embedding_dimensions': null,
      });
      expect(detail.embeddingDimensions, isNull);
    });

    test('copyWith and equality are value-based', () {
      final detail = SearchIndexSchemaDetail.fromJson(json);
      expect(detail, SearchIndexSchemaDetail.fromJson(json));
      expect(detail.copyWith(name: 'other').name, 'other');
      expect(detail.toString(), contains('schema-1'));
    });
  });

  group('SearchIndexSchemaSdFile model', () {
    test('round-trips through JSON', () {
      final file = SearchIndexSchemaSdFile.fromJson(const {
        'content': 'schema {}',
      });
      expect(file.content, 'schema {}');
      expect(file.toJson(), {'content': 'schema {}'});
    });

    test('handles null content', () {
      final file = SearchIndexSchemaSdFile.fromJson(const {'content': null});
      expect(file.content, isNull);
      expect(file.copyWith(content: null).content, isNull);
      expect(file.copyWith().content, isNull);
    });

    test('equality is value-based', () {
      final a = SearchIndexSchemaSdFile.fromJson(const {'content': 'x'});
      final b = SearchIndexSchemaSdFile.fromJson(const {'content': 'x'});
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toString(), contains('x'));
    });
  });

  group('VespaSchemaSummary model', () {
    final json = {'id': 'schema-uuid', 'name': 'schema-1', 'document_count': 3};

    test('round-trips through JSON', () {
      final summary = VespaSchemaSummary.fromJson(json);
      expect(summary.id, 'schema-uuid');
      expect(summary.documentCount, 3);
      expect(summary.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final summary = VespaSchemaSummary.fromJson(json);
      expect(summary, VespaSchemaSummary.fromJson(json));
      expect(summary.copyWith(documentCount: null).documentCount, isNull);
      expect(summary.toString(), contains('schema-1'));
    });
  });

  group('VespaIndexSummary model', () {
    final schemaJson = {
      'id': 'schema-uuid',
      'name': 'schema-1',
      'document_count': 3,
    };
    final json = {
      'type': 'vespa',
      'k8s_cluster': 'cluster',
      'k8s_namespace': 'namespace',
      'vespa_instance_name': 'instance',
      'schemas': [schemaJson],
    };

    test('round-trips through JSON', () {
      final summary = VespaIndexSummary.fromJson(json);
      expect(summary.k8sCluster, 'cluster');
      expect(summary.schemas.single.name, 'schema-1');
      expect(summary.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final summary = VespaIndexSummary.fromJson(json);
      expect(summary, VespaIndexSummary.fromJson(json));
      expect(summary.copyWith(k8sCluster: 'other').k8sCluster, 'other');
      expect(summary.toString(), contains('cluster'));
    });
  });

  group('SearchIndexSummary model', () {
    final indexJson = {
      'type': 'vespa',
      'k8s_cluster': 'cluster',
      'k8s_namespace': 'namespace',
      'vespa_instance_name': 'instance',
      'schemas': <Map<String, dynamic>>[],
    };
    final json = {
      'id': 'idx-1',
      'name': 'My index',
      'creator_id': 'user-1',
      'document_count': 10,
      'status': 'online',
      'created_at': '2024-01-01T00:00:00.000Z',
      'modified_at': '2024-01-02T00:00:00.000Z',
      'index': indexJson,
    };

    test('round-trips through JSON', () {
      final summary = SearchIndexSummary.fromJson(json);
      expect(summary.id, 'idx-1');
      expect(summary.status, SearchIndexStatus.online);
      expect(summary.index.k8sCluster, 'cluster');
      expect(summary.toJson(), json);
    });

    test('unknown status falls back to unknown', () {
      final summary = SearchIndexSummary.fromJson({
        ...json,
        'status': 'archived',
      });
      expect(summary.status, SearchIndexStatus.unknown);
    });

    test('copyWith and equality are value-based', () {
      final summary = SearchIndexSummary.fromJson(json);
      expect(summary, SearchIndexSummary.fromJson(json));
      expect(summary.copyWith(name: 'Renamed').name, 'Renamed');
      expect(summary.toString(), contains('My index'));
    });
  });

  group('SearchIndexRetrievable model', () {
    final json = {
      'id': 'doc-1',
      'fields': {'title': 'Doc 1', 'score': 0.9},
    };

    test('round-trips through JSON', () {
      final retrievable = SearchIndexRetrievable.fromJson(json);
      expect(retrievable.id, 'doc-1');
      expect(retrievable.fields, {'title': 'Doc 1', 'score': 0.9});
      expect(retrievable.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final retrievable = SearchIndexRetrievable.fromJson(json);
      expect(retrievable, SearchIndexRetrievable.fromJson(json));
      expect(
        retrievable.hashCode,
        SearchIndexRetrievable.fromJson(json).hashCode,
      );
      expect(retrievable.copyWith(id: 'doc-2').id, 'doc-2');
      expect(retrievable.toString(), contains('doc-1'));
    });
  });

  group('SummaryFieldResponse model', () {
    final json = {
      'content': 'A summary.',
      'status': 'handwritten',
      'translated': false,
    };

    test('round-trips through JSON', () {
      final response = SummaryFieldResponse.fromJson(json);
      expect(response.content, 'A summary.');
      expect(response.status, SummaryStatus.handwritten);
      expect(response.translated, isFalse);
      expect(response.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final response = SummaryFieldResponse.fromJson(json);
      expect(response, SummaryFieldResponse.fromJson(json));
      expect(response.copyWith(translated: true).translated, isTrue);
      expect(response.toString(), contains('A summary.'));
    });
  });

  group('UpdateSummaryRequest model', () {
    final json = {
      'content': 'A summary.',
      'status': 'generated_confirmed',
      'translated': true,
    };

    test('round-trips through JSON', () {
      final request = UpdateSummaryRequest.fromJson(json);
      expect(request.status, SummaryStatus.generatedConfirmed);
      expect(request.translated, isTrue);
      expect(request.toJson(), json);
    });

    test('copyWith and equality are value-based', () {
      final request = UpdateSummaryRequest.fromJson(json);
      expect(request, UpdateSummaryRequest.fromJson(json));
      expect(request.copyWith(content: 'Other').content, 'Other');
      expect(request.toString(), contains('A summary.'));
    });
  });

  group('SchemaMetrics model', () {
    test('round-trips through JSON', () {
      final metrics = SchemaMetrics.fromJson(const {
        'name': 'schema-1',
        'document_count': 42,
      });
      expect(metrics.name, 'schema-1');
      expect(metrics.documentCount, 42);
      expect(metrics.toJson(), {'name': 'schema-1', 'document_count': 42});
      expect(
        metrics,
        SchemaMetrics.fromJson(const {
          'name': 'schema-1',
          'document_count': 42,
        }),
      );
      expect(metrics.copyWith(documentCount: 43).documentCount, 43);
      expect(metrics.toString(), contains('schema-1'));
    });
  });

  group('UpdateIndexMetricsRequest sealed union', () {
    test('dispatches to UpdateIndexMetricsOnlineRequest on status=online', () {
      final json = {
        'status': 'online',
        'document_count': 10,
        'schema_metrics': [
          {'name': 'schema-1', 'document_count': 10},
        ],
      };
      final request = UpdateIndexMetricsRequest.fromJson(json);
      expect(request, isA<UpdateIndexMetricsOnlineRequest>());
      request as UpdateIndexMetricsOnlineRequest;
      expect(request.documentCount, 10);
      expect(request.schemaMetrics.single.name, 'schema-1');
      expect(request.toJson(), json);
      expect(request.status, 'online');
    });

    test(
      'dispatches to UpdateIndexMetricsOfflineRequest on status=offline',
      () {
        final json = {'status': 'offline', 'clear_metrics': true};
        final request = UpdateIndexMetricsRequest.fromJson(json);
        expect(request, isA<UpdateIndexMetricsOfflineRequest>());
        request as UpdateIndexMetricsOfflineRequest;
        expect(request.clearMetrics, isTrue);
        expect(request.toJson(), json);
      },
    );

    test('defaults clear_metrics to false when omitted', () {
      final request =
          UpdateIndexMetricsRequest.fromJson({'status': 'offline'})
              as UpdateIndexMetricsOfflineRequest;
      expect(request.clearMetrics, isFalse);
    });

    test('throws FormatException for unknown status', () {
      expect(
        () => UpdateIndexMetricsRequest.fromJson({'status': 'archived'}),
        throwsFormatException,
      );
    });

    test('copyWith and equality are value-based per variant', () {
      const online = UpdateIndexMetricsOnlineRequest(
        documentCount: 1,
        schemaMetrics: [SchemaMetrics(name: 'schema-1', documentCount: 1)],
      );
      expect(
        online,
        const UpdateIndexMetricsOnlineRequest(
          documentCount: 1,
          schemaMetrics: [SchemaMetrics(name: 'schema-1', documentCount: 1)],
        ),
      );
      expect(online.copyWith(documentCount: 2).documentCount, 2);
      expect(online.toString(), contains('documentCount: 1'));

      const offline = UpdateIndexMetricsOfflineRequest();
      expect(offline, const UpdateIndexMetricsOfflineRequest());
      expect(offline.copyWith(clearMetrics: true).clearMetrics, isTrue);
      expect(offline.toString(), contains('clearMetrics: false'));
    });
  });

  group('SummaryStreamEvent sealed union (key dispatch)', () {
    test('dispatches to SummaryStreamMetadata when no content/error key', () {
      final event = SummaryStreamEvent.fromJson({
        'status': 'generated',
        'translated': false,
      });
      expect(event, isA<SummaryStreamMetadata>());
      event as SummaryStreamMetadata;
      expect(event.status, SummaryStatus.generated);
      expect(event.translated, isFalse);
      expect(event.toJson(), {'status': 'generated', 'translated': false});
    });

    test('dispatches to SummaryStreamChunk when content key present', () {
      final event = SummaryStreamEvent.fromJson({'content': 'chunk text'});
      expect(event, isA<SummaryStreamChunk>());
      event as SummaryStreamChunk;
      expect(event.content, 'chunk text');
      expect(event.toJson(), {'content': 'chunk text'});
    });

    test('dispatches to SummaryStreamError when error key present', () {
      final event = SummaryStreamEvent.fromJson({'error': 'boom'});
      expect(event, isA<SummaryStreamError>());
      event as SummaryStreamError;
      expect(event.error, 'boom');
      expect(event.toJson(), {'error': 'boom'});
    });

    test('copyWith and equality are value-based per variant', () {
      const metadata = SummaryStreamMetadata(
        status: SummaryStatus.handwritten,
        translated: true,
      );
      expect(
        metadata,
        const SummaryStreamMetadata(
          status: SummaryStatus.handwritten,
          translated: true,
        ),
      );
      expect(metadata.copyWith(translated: false).translated, isFalse);
      expect(metadata.toString(), contains('handwritten'));

      const chunk = SummaryStreamChunk(content: 'a');
      expect(chunk, const SummaryStreamChunk(content: 'a'));
      expect(chunk.copyWith(content: 'b').content, 'b');
      expect(chunk.toString(), contains('a'));

      const error = SummaryStreamError(error: 'oops');
      expect(error, const SummaryStreamError(error: 'oops'));
      expect(error.copyWith(error: 'other').error, 'other');
      expect(error.toString(), contains('oops'));
    });
  });

  group('Schema field enums', () {
    test('SchemaFieldDataType maps keyword-colliding values', () {
      expect(
        SchemaFieldDataType.fromString('int'),
        SchemaFieldDataType.intType,
      );
      expect(
        SchemaFieldDataType.fromString('bool'),
        SchemaFieldDataType.boolType,
      );
      expect(
        SchemaFieldDataType.fromString('string'),
        SchemaFieldDataType.stringType,
      );
      expect(SchemaFieldDataType.fromString('long'), SchemaFieldDataType.long);
      expect(
        SchemaFieldDataType.fromString('float'),
        SchemaFieldDataType.float,
      );
      expect(
        SchemaFieldDataType.fromString('???'),
        SchemaFieldDataType.unknown,
      );
      expect(SchemaFieldDataType.fromString(null), SchemaFieldDataType.unknown);
      expect(SchemaFieldDataType.intType.toJson(), 'int');
    });

    test('SchemaFieldIndex maps values both ways', () {
      expect(SchemaFieldIndex.fromString('ann'), SchemaFieldIndex.ann);
      expect(SchemaFieldIndex.fromString('bm25'), SchemaFieldIndex.bm25);
      expect(
        SchemaFieldIndex.fromString('attribute'),
        SchemaFieldIndex.attribute,
      );
      expect(SchemaFieldIndex.fromString('???'), SchemaFieldIndex.unknown);
      expect(SchemaFieldIndex.ann.toJson(), 'ann');
    });

    test('SchemaFieldRankingType maps keyword-colliding values', () {
      expect(
        SchemaFieldRankingType.fromString('count'),
        SchemaFieldRankingType.count,
      );
      expect(
        SchemaFieldRankingType.fromString('embedding'),
        SchemaFieldRankingType.embedding,
      );
      expect(
        SchemaFieldRankingType.fromString('timestamp'),
        SchemaFieldRankingType.timestamp,
      );
      expect(
        SchemaFieldRankingType.fromString('text'),
        SchemaFieldRankingType.text,
      );
      expect(
        SchemaFieldRankingType.fromString('string'),
        SchemaFieldRankingType.stringType,
      );
      expect(
        SchemaFieldRankingType.fromString('bool'),
        SchemaFieldRankingType.boolType,
      );
      expect(
        SchemaFieldRankingType.fromString('int'),
        SchemaFieldRankingType.intType,
      );
      expect(
        SchemaFieldRankingType.fromString('language'),
        SchemaFieldRankingType.language,
      );
      expect(
        SchemaFieldRankingType.fromString('???'),
        SchemaFieldRankingType.unknown,
      );
    });

    test('SchemaFieldStorage maps values both ways', () {
      expect(
        SchemaFieldStorage.fromString('in_memory'),
        SchemaFieldStorage.inMemory,
      );
      expect(
        SchemaFieldStorage.fromString('on_disk'),
        SchemaFieldStorage.onDisk,
      );
      expect(SchemaFieldStorage.fromString('???'), SchemaFieldStorage.unknown);
      expect(SchemaFieldStorage.inMemory.toJson(), 'in_memory');
    });

    test('SummaryStatus maps values both ways', () {
      expect(
        SummaryStatus.fromString('handwritten'),
        SummaryStatus.handwritten,
      );
      expect(SummaryStatus.fromString('generated'), SummaryStatus.generated);
      expect(
        SummaryStatus.fromString('generated_confirmed'),
        SummaryStatus.generatedConfirmed,
      );
      expect(SummaryStatus.fromString('???'), SummaryStatus.unknown);
      expect(SummaryStatus.handwritten.toJson(), 'handwritten');
    });

    test('SummaryLanguage maps values both ways', () {
      expect(SummaryLanguage.fromString('en'), SummaryLanguage.en);
      expect(SummaryLanguage.fromString('pt_br'), SummaryLanguage.ptBr);
      expect(SummaryLanguage.fromString('???'), SummaryLanguage.unknown);
      expect(SummaryLanguage.en.toJson(), 'en');
    });
  });
}
