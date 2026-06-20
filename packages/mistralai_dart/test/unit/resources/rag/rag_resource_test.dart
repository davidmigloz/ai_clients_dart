@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RagResource', () {
    late http.Request captured;

    MistralClient clientReturning(Object body, {int statusCode = 200}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    Map<String, dynamic> configJson(String id) => {
      'id': id,
      'author_id': 'author-1',
      'name': 'My pipeline',
      'created_at': '2024-01-01T00:00:00.000Z',
      'modified_at': '2024-01-02T00:00:00.000Z',
      'last_run_time': null,
      'last_run_chunks_count': 0,
      'total_chunks_count': 0,
      'pipeline_composition': null,
    };

    Map<String, dynamic> searchIndexJson(String id) => {
      'id': id,
      'name': 'My index',
      'creator_id': 'user-1',
      'document_count': 12,
      'status': 'online',
      'created_at': '2024-01-01T00:00:00.000Z',
      'modified_at': '2024-01-02T00:00:00.000Z',
      'index': {
        'type': 'vespa',
        'k8s_cluster': 'cluster',
        'k8s_namespace': 'namespace',
        'vespa_instance_name': 'instance',
        'schemas': [
          {'name': 'schema-1', 'document_count': 12},
        ],
      },
    };

    group('ingestionPipelineConfigurations', () {
      test('list issues GET and parses the array', () async {
        final client = clientReturning([configJson('cfg-1')]);
        addTearDown(client.close);

        final result = await client.rag.ingestionPipelineConfigurations.list();

        expect(captured.method, 'GET');
        expect(captured.url.path, '/v1/rag/ingestion_pipeline_configurations');
        expect(result.single.id, 'cfg-1');
        expect(result.single.name, 'My pipeline');
      });

      test('register issues PUT with the request body', () async {
        final client = clientReturning(configJson('cfg-2'));
        addTearDown(client.close);

        final result = await client.rag.ingestionPipelineConfigurations
            .register(
              request: const CreateIngestionPipelineConfigurationRequest(
                name: 'My pipeline',
                pipelineComposition: {'stage': 'component'},
              ),
            );

        expect(captured.method, 'PUT');
        expect(captured.url.path, '/v1/rag/ingestion_pipeline_configurations');
        expect(jsonDecode(captured.body), {
          'name': 'My pipeline',
          'pipeline_composition': {'stage': 'component'},
        });
        expect(result.id, 'cfg-2');
      });

      test('updateRunInfo issues PUT with id in the path', () async {
        final client = clientReturning(configJson('cfg-3'));
        addTearDown(client.close);

        final result = await client.rag.ingestionPipelineConfigurations
            .updateRunInfo(
              id: 'cfg-3',
              request: UpdateRunInfo(
                executionTime: DateTime.utc(2024, 1, 5),
                chunksCount: 9,
              ),
            );

        expect(captured.method, 'PUT');
        expect(
          captured.url.path,
          '/v1/rag/ingestion_pipeline_configurations/cfg-3/run_info',
        );
        expect(jsonDecode(captured.body), {
          'execution_time': '2024-01-05T00:00:00.000Z',
          'chunks_count': 9,
        });
        expect(result.id, 'cfg-3');
      });
    });

    group('searchIndexes', () {
      test('list issues GET and parses the array', () async {
        final client = clientReturning([searchIndexJson('idx-1')]);
        addTearDown(client.close);

        final result = await client.rag.searchIndexes.list();

        expect(captured.method, 'GET');
        expect(captured.url.path, '/v1/rag/search_index');
        expect(result.single.id, 'idx-1');
        expect(result.single.status, SearchIndexStatus.online);
        expect(result.single.index.schemas.single.name, 'schema-1');
      });

      test('register issues PUT with the request body', () async {
        final client = clientReturning(searchIndexJson('idx-2'));
        addTearDown(client.close);

        final result = await client.rag.searchIndexes.register(
          request: const CreateSearchIndexInfoRequest(
            name: 'My index',
            index: CreateVespaSearchIndexInfoRequest(
              k8sCluster: 'cluster',
              k8sNamespace: 'namespace',
              vespaInstanceName: 'instance',
              schemas: [CreateVespaSchemaRequest(name: 'schema-1')],
            ),
          ),
        );

        expect(captured.method, 'PUT');
        expect(captured.url.path, '/v1/rag/search_index');
        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['name'], 'My index');
        expect(body['status'], 'offline');
        expect((body['index'] as Map)['type'], 'vespa');
        expect(result.id, 'idx-2');
      });
    });
  });
}
