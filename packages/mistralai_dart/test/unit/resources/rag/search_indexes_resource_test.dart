@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SearchIndexesResource', () {
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

    const registerRequest = RegisterSearchIndexRequest(
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

    Map<String, dynamic> indexJson() => {
      'type': 'vespa',
      'k8s_cluster': 'cluster',
      'k8s_namespace': 'namespace',
      'vespa_instance_name': 'instance',
      'schemas': <Map<String, dynamic>>[],
    };

    test(
      'register issues PUT to /v1/rag/indexes with the request body',
      () async {
        final client = clientReturning({'id': 'idx-1'});
        addTearDown(client.close);

        final result = await client.rag.searchIndexes.register(
          request: registerRequest,
        );

        expect(captured.method, 'PUT');
        expect(captured.url.path, '/v1/rag/indexes');
        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['name'], 'My index');
        expect(body['status'], 'offline');
        expect((body['index'] as Map)['type'], 'vespa');
        expect(result.id, 'idx-1');
      },
    );

    test('unregister issues DELETE with the index ID in the path', () async {
      final client = clientReturning('');
      addTearDown(client.close);

      await client.rag.searchIndexes.unregister(indexId: 'idx-1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v1/rag/indexes/index/idx-1');
    });

    test('getDetail issues GET and parses the response', () async {
      final client = clientReturning({
        'name': 'My index',
        'creator_id': 'user-1',
        'document_count': 5,
        'status': 'online',
        'created_at': '2024-01-01T00:00:00.000Z',
        'modified_at': '2024-01-02T00:00:00.000Z',
        'vespa_version': '8.0.0',
        'schemas': <Map<String, dynamic>>[],
      });
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.getDetail(indexId: 'idx-1');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/rag/indexes/index/idx-1/detail');
      expect(result.name, 'My index');
      expect(result.status, SearchIndexStatus.online);
    });

    test('updateMetrics issues PUT with an online request body', () async {
      final client = clientReturning('');
      addTearDown(client.close);

      await client.rag.searchIndexes.updateMetrics(
        indexId: 'idx-1',
        request: const UpdateIndexMetricsOnlineRequest(
          documentCount: 10,
          schemaMetrics: [SchemaMetrics(name: 'schema-1', documentCount: 10)],
        ),
      );

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/v1/rag/indexes/index/idx-1/metrics');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['status'], 'online');
      expect(body['document_count'], 10);
    });

    test('updateMetrics issues PUT with an offline request body', () async {
      final client = clientReturning('');
      addTearDown(client.close);

      await client.rag.searchIndexes.updateMetrics(
        indexId: 'idx-1',
        request: const UpdateIndexMetricsOfflineRequest(clearMetrics: true),
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body, {'status': 'offline', 'clear_metrics': true});
    });

    test('listSummaries issues GET and parses the array', () async {
      final client = clientReturning([
        {
          'id': 'idx-1',
          'name': 'My index',
          'creator_id': 'user-1',
          'document_count': 5,
          'status': 'online',
          'created_at': '2024-01-01T00:00:00.000Z',
          'modified_at': '2024-01-02T00:00:00.000Z',
          'index': indexJson(),
        },
      ]);
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.listSummaries();

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/rag/indexes/summary');
      expect(result.single.id, 'idx-1');
      expect(result.single.index.k8sCluster, 'cluster');
    });

    test('getSchemaDetail issues GET with index and schema IDs', () async {
      final client = clientReturning({
        'name': 'schema-1',
        'embedding_dimensions': 1536,
        'fields': <Map<String, dynamic>>[],
      });
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.getSchemaDetail(
        indexId: 'idx-1',
        schemaId: 'schema-1',
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1/detail',
      );
      expect(result.embeddingDimensions, 1536);
    });

    test('getSchemaFile issues GET with index and schema IDs', () async {
      final client = clientReturning({'content': 'schema {}'});
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.getSchemaFile(
        indexId: 'idx-1',
        schemaId: 'schema-1',
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1/file',
      );
      expect(result.content, 'schema {}');
    });

    test('listRetrievables issues GET without group_id by default', () async {
      final client = clientReturning([
        {
          'id': 'doc-1',
          'fields': {'title': 'Doc 1'},
        },
      ]);
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.listRetrievables(
        indexId: 'idx-1',
        schemaId: 'schema-1',
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1/retrievables',
      );
      expect(captured.url.queryParameters.containsKey('group_id'), isFalse);
      expect(result.single.id, 'doc-1');
    });

    test('listRetrievables forwards group_id as a query parameter', () async {
      final client = clientReturning(<Map<String, dynamic>>[]);
      addTearDown(client.close);

      await client.rag.searchIndexes.listRetrievables(
        indexId: 'idx-1',
        schemaId: 'schema-1',
        groupId: 'group-1',
      );

      expect(captured.url.queryParameters['group_id'], 'group-1');
    });

    test('getRetrievable issues GET with document ID in the path', () async {
      final client = clientReturning({
        'id': 'doc-1',
        'fields': {'title': 'Doc 1'},
      });
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.getRetrievable(
        indexId: 'idx-1',
        schemaId: 'schema-1',
        documentId: 'doc-1',
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1'
        '/retrievables/retrievable/doc-1',
      );
      expect(result.fields, {'title': 'Doc 1'});
    });

    test('getSummary issues GET on the index summary_field path', () async {
      final client = clientReturning({
        'content': 'A summary.',
        'status': 'handwritten',
        'translated': false,
      });
      addTearDown(client.close);

      final result = await client.rag.searchIndexes.getSummary(
        indexId: 'idx-1',
        language: SummaryLanguage.en,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/rag/indexes/index/idx-1/summary_field/en');
      expect(result.status, SummaryStatus.handwritten);
    });

    test('setSummary issues PUT with the request body', () async {
      final client = clientReturning('');
      addTearDown(client.close);

      await client.rag.searchIndexes.setSummary(
        indexId: 'idx-1',
        language: SummaryLanguage.fr,
        request: const UpdateSummaryRequest(
          content: 'A summary.',
          status: SummaryStatus.handwritten,
          translated: false,
        ),
      );

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/v1/rag/indexes/index/idx-1/summary_field/fr');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['content'], 'A summary.');
      expect(body['status'], 'handwritten');
    });

    test(
      'getSchemaSummary issues GET on the schema summary_field path',
      () async {
        final client = clientReturning({
          'content': 'A summary.',
          'status': 'generated',
          'translated': true,
        });
        addTearDown(client.close);

        final result = await client.rag.searchIndexes.getSchemaSummary(
          indexId: 'idx-1',
          schemaId: 'schema-1',
          language: SummaryLanguage.de,
        );

        expect(captured.method, 'GET');
        expect(
          captured.url.path,
          '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1/summary_field/de',
        );
        expect(result.status, SummaryStatus.generated);
      },
    );

    test('setSchemaSummary issues PUT with the request body', () async {
      final client = clientReturning('');
      addTearDown(client.close);

      await client.rag.searchIndexes.setSchemaSummary(
        indexId: 'idx-1',
        schemaId: 'schema-1',
        language: SummaryLanguage.nl,
        request: const UpdateSummaryRequest(
          content: 'A summary.',
          status: SummaryStatus.generatedConfirmed,
          translated: true,
        ),
      );

      expect(captured.method, 'PUT');
      expect(
        captured.url.path,
        '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1/summary_field/nl',
      );
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['status'], 'generated_confirmed');
    });
  });

  group('SearchIndexesResource streaming', () {
    Uri? capturedUrl;
    String? capturedMethod;

    MistralClient streamingClient(List<String> ndjsonLines) {
      final mockClient = MockClient.streaming((request, _) async {
        capturedUrl = request.url;
        capturedMethod = request.method;
        return http.StreamedResponse(
          Stream.fromIterable(ndjsonLines.map(utf8.encode)),
          200,
        );
      });

      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('generateSummary streams NDJSON into typed events', () async {
      final client = streamingClient([
        '${jsonEncode({'status': 'generated', 'translated': false})}\n',
        '${jsonEncode({'content': 'Hello '})}\n',
        '${jsonEncode({'content': 'world'})}\n',
      ]);
      addTearDown(client.close);

      final events = await client.rag.searchIndexes
          .generateSummary(indexId: 'idx-1', language: SummaryLanguage.en)
          .toList();

      expect(capturedMethod, 'POST');
      expect(capturedUrl?.path, '/v1/rag/indexes/index/idx-1/summary_field/en');
      expect(events, hasLength(3));
      expect(events[0], isA<SummaryStreamMetadata>());
      expect(
        (events[0] as SummaryStreamMetadata).status,
        SummaryStatus.generated,
      );
      expect(events[1], isA<SummaryStreamChunk>());
      expect((events[1] as SummaryStreamChunk).content, 'Hello ');
      expect((events[2] as SummaryStreamChunk).content, 'world');
    });

    test('generateSummary surfaces a SummaryStreamError event', () async {
      final client = streamingClient([
        '${jsonEncode({'error': 'generation failed'})}\n',
      ]);
      addTearDown(client.close);

      final events = await client.rag.searchIndexes
          .generateSummary(indexId: 'idx-1', language: SummaryLanguage.en)
          .toList();

      expect(events.single, isA<SummaryStreamError>());
      expect((events.single as SummaryStreamError).error, 'generation failed');
    });

    test(
      'generateSchemaSummary issues POST on the schema summary path',
      () async {
        final client = streamingClient([
          '${jsonEncode({'content': 'chunk'})}\n',
        ]);
        addTearDown(client.close);

        final events = await client.rag.searchIndexes
            .generateSchemaSummary(
              indexId: 'idx-1',
              schemaId: 'schema-1',
              language: SummaryLanguage.es,
            )
            .toList();

        expect(capturedMethod, 'POST');
        expect(
          capturedUrl?.path,
          '/v1/rag/indexes/index/idx-1/schemas/schema/schema-1/summary_field/es',
        );
        expect(events.single, isA<SummaryStreamChunk>());
      },
    );
  });
}
