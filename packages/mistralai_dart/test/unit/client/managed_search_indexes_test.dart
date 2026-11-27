import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _path = '/v1/context/search-indexes';
const _index = 'platform notes';
const _indexPath = '$_path/platform%20notes';
const _chunkPath = '$_indexPath/chunks/chunk%2F1';
const _summaryPath = '$_indexPath/summary_field/en';

const Map<String, Object> _indexPayload = {
  'id': 'mock-index-id',
  'name': _index,
  'creator_id': 'creator',
  'status': 'provisioning',
  'schema': {
    'document_fields': {
      'team': {'type': 'keyword[]', 'indexed': true},
    },
  },
  'config': {
    'embedding': {
      'type': 'mistral',
      'name': 'mistral-embed',
      'dimensions': 1024,
    },
  },
};

const Map<String, Object?> _chunk = {
  'id': 'chunk/1',
  'source_id': 'source-1',
  'locator': 'page-1',
  'start_offset': 0,
  'end_offset': null,
  'chunk_type': 'text',
  'content': 'Workspace notes',
  'team': ['platform'],
};

const Map<String, Object> _summary = {
  'content': 'Internal notes',
  'status': 'handwritten',
  'translated': false,
};

typedef _Exchange = ({
  String method,
  String url,
  int status,
  Object response,
  Object? request,
});

MistralClient _testClient(http.Client httpClient) {
  final client = MistralClient(
    config: const MistralConfig(authProvider: ApiKeyProvider('fixture-key')),
    httpClient: httpClient,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  test('public Managed Search calls match the 14 JSON operations', () async {
    final exchanges = Queue<_Exchange>();

    void willRespond(
      String method,
      String url,
      Object response, {
      Object? request,
      int status = 200,
    }) => exchanges.add((
      method: method,
      url: url,
      status: status,
      response: response,
      request: request,
    ));

    final client = _testClient(
      MockClient((request) async {
        expect(exchanges, isNotEmpty);
        final expected = exchanges.removeFirst();
        expect(request.method, expected.method);
        expect(request.url.toString(), 'https://api.mistral.ai${expected.url}');
        expect(request.headers['authorization'], 'Bearer fixture-key');
        expect(request.headers['accept'], 'application/json');
        if (expected.request == null) {
          expect(request.body, isEmpty);
        } else {
          expect(request.headers['content-type'], contains('application/json'));
          expect(jsonDecode(request.body), expected.request);
        }
        return http.Response(jsonEncode(expected.response), expected.status);
      }),
    );
    final indexes = client.managedSearchIndexes;

    willRespond(
      'GET',
      '$_path?page_size=2&page_token=cursor%2Bnext&name=notes&status=ready&creator_id=creator',
      {
        'data': [_indexPayload],
        'next_page_token': 'opaque',
      },
    );
    final page = await indexes.list(
      pageSize: 2,
      pageToken: 'cursor+next',
      name: 'notes',
      status: ManagedSearchIndexStatus.ready,
      creatorId: 'creator',
    );
    expect(page.nextPageToken, 'opaque');
    expect(page.data.single.status, ManagedSearchIndexStatus.provisioning);

    willRespond(
      'POST',
      _path,
      _indexPayload,
      request: {
        'name': _index,
        'config': {
          'embedding': {
            'type': 'mistral',
            'name': 'mistral-embed',
            'dimensions': 1024,
          },
        },
      },
      status: 202,
    );
    final created = await indexes.create(
      request: const CreateManagedIndexRequest(
        name: _index,
        config: ManagedIndexConfig(
          embedding: MistralIndexEmbedding(
            name: 'mistral-embed',
            dimensions: 1024,
          ),
        ),
      ),
    );
    expect(created.name, _index);
    expect(created.toJson(), _indexPayload);

    willRespond('GET', _indexPath, {..._indexPayload, 'status': 'ready'});
    expect(
      (await indexes.get(indexName: _index)).status,
      ManagedSearchIndexStatus.ready,
    );

    willRespond(
      'PUT',
      _indexPath,
      _indexPayload,
      request: {
        'schema': {
          'document_fields': {
            'team': {'type': 'keyword[]', 'indexed': true},
          },
        },
      },
      status: 202,
    );
    await indexes.update(
      indexName: _index,
      request: const UpdateManagedIndexRequest(
        schema: ManagedIndexFields(
          documentFields: {
            'team': ManagedIndexField(type: 'keyword[]', indexed: true),
          },
        ),
      ),
    );

    willRespond(
      'POST',
      '$_indexPath/documents',
      {
        'accepted': 1,
        'rejected': 1,
        'results': [
          {
            'status': 'accepted',
            'position': 0,
            'document_id': 'source-1',
            'chunk_count': 1,
          },
          {
            'status': 'rejected',
            'position': 1,
            'errors': [
              {
                'location': ['body', 1, 'content'],
                'message': 'Required',
                'type': 'missing',
              },
            ],
          },
        ],
      },
      request: {
        'documents': [
          {
            'content': 'Workspace notes',
            'team': ['platform'],
          },
          {
            'team': ['platform'],
          },
        ],
      },
    );
    final ingestion = await indexes.ingestDocuments(
      indexName: _index,
      request: const IngestSearchDocumentsRequest(
        documents: [
          {
            'content': 'Workspace notes',
            'team': ['platform'],
          },
          {
            'team': ['platform'],
          },
        ],
      ),
    );
    expect(ingestion.results.first, isA<AcceptedSearchDocument>());
    final rejected = ingestion.results.last as RejectedSearchDocument;
    expect(rejected.errors.single.location, ['body', 1, 'content']);

    willRespond(
      'POST',
      '$_indexPath/search',
      {
        'hits': [
          {'index_name': _index, 'score': 0.9, 'chunk': _chunk},
        ],
      },
      request: {
        'retriever': {
          'type': 'keyword',
          'query': 'workspace',
          'filter': {'type': 'equal', 'field': 'team', 'value': 'platform'},
        },
      },
    );
    final search = await indexes.search(
      indexName: _index,
      request: const ManagedSearchRequest(
        retriever: KeywordRetriever(
          query: 'workspace',
          filter: SearchEqualFilter(field: 'team', value: 'platform'),
        ),
      ),
    );
    final hit = search.hits.single;
    expect(hit.score, 0.9);
    expect(hit.chunk.extra, {
      'team': ['platform'],
    });
    expect(hit.chunk.toJson(), _chunk);

    willRespond(
      'POST',
      '$_indexPath/navigate',
      {
        'chunks': [_chunk],
      },
      request: {
        'source_id': 'source-1',
        'direction': 'next',
        'start_offset': 0,
        'end_offset': 7,
      },
    );
    expect(
      (await indexes.navigate(
        indexName: _index,
        request: const SearchNavigateRequest(
          sourceId: 'source-1',
          startOffset: 0,
          endOffset: 7,
          direction: SearchNavigationDirection.next,
        ),
      )).chunks.single.content,
      'Workspace notes',
    );

    willRespond(
      'POST',
      '$_indexPath/read',
      {
        'chunks': [_chunk],
      },
      request: {'source_id': 'source-1', 'start_offset': 0, 'end_offset': 7},
    );
    await indexes.read(
      indexName: _index,
      request: const SearchReadRequest(
        sourceId: 'source-1',
        startOffset: 0,
        endOffset: 7,
      ),
    );

    willRespond(
      'POST',
      '$_indexPath/grep',
      {
        'chunks': [_chunk],
      },
      request: {
        'source_id': 'source-1',
        'pattern': 'workspace',
        'mode': 'term',
      },
    );
    await indexes.grep(
      indexName: _index,
      request: const SearchGrepRequest(
        sourceId: 'source-1',
        pattern: 'workspace',
        mode: SearchGrepMode.term,
      ),
    );

    willRespond('GET', _chunkPath, {
      'chunks': [_chunk],
    });
    expect(
      (await indexes.getChunk(
        indexName: _index,
        chunkId: 'chunk/1',
      )).chunks.single.id,
      'chunk/1',
    );

    willRespond('GET', _summaryPath, _summary);
    expect(
      (await indexes.getSummary(
        indexName: _index,
        language: SummaryLanguage.en,
      )).content,
      'Internal notes',
    );
    willRespond('PUT', _summaryPath, <String, Object>{}, request: _summary);
    await indexes.setSummary(
      indexName: _index,
      language: SummaryLanguage.en,
      request: const UpdateSummaryRequest(
        content: 'Internal notes',
        status: SummaryStatus.handwritten,
        translated: false,
      ),
    );

    willRespond(
      'DELETE',
      '$_indexPath/documents',
      {
        'deleted_document_ids': ['source-1'],
        'missing': <String>[],
      },
      request: {
        'document_ids': ['source-1'],
      },
    );
    expect(
      (await indexes.deleteDocuments(
        indexName: _index,
        request: const DeleteSearchDocumentsRequest(documentIds: ['source-1']),
      )).deletedDocumentIds,
      ['source-1'],
    );

    willRespond('DELETE', _indexPath, {
      'id': 'mock-index-id',
      'name': _index,
      'status': 'deleting',
    }, status: 202);
    expect(
      (await indexes.delete(indexName: _index)).status,
      ManagedSearchIndexStatus.deleting,
    );
    expect(exchanges, isEmpty);
  });

  test('hybrid retrievers and nested filters round-trip', () {
    const wire = {
      'retriever': {
        'type': 'rrf',
        'top_k': 8,
        'weights': [1, 2],
        'retrievers': [
          {'type': 'keyword', 'query': 'release'},
          {
            'type': 'nearest_neighbour',
            'query_embedding': [0.3, 0.4],
            'max_candidates': 20,
          },
        ],
        'filter': {
          'type': 'and',
          'matches': [
            {
              'type': 'in',
              'field': 'project',
              'values': ['dart', 'flutter'],
            },
            {'type': 'range', 'field': 'version', 'gte': 8},
          ],
        },
      },
    };
    final request = ManagedSearchRequest.fromJson(wire);
    final retriever = request.retriever as RrfRetriever;
    expect(retriever.retrievers.last, isA<NearestNeighbourRetriever>());
    expect(retriever.filter, isA<SearchAndFilter>());
    expect(request.toJson(), wire);
    expect(ManagedSearchRequest.fromJson(wire).hashCode, request.hashCode);
  });

  test(
    'JSON and summary HTTP errors retain normal exception handling',
    () async {
      final client = _testClient(
        MockClient((request) async {
          expect(request.url.pathSegments, contains('context'));
          return http.Response('{"message":"Search access denied"}', 403);
        }),
      );

      final forbidden = isA<ApiException>().having(
        (error) => error.statusCode,
        'statusCode',
        403,
      );
      await expectLater(
        client.managedSearchIndexes.get(indexName: _index),
        throwsA(forbidden),
      );
      await expectLater(
        client.managedSearchIndexes.generateSummary(
          indexName: _index,
          language: SummaryLanguage.en,
        ),
        emitsError(forbidden),
      );
    },
  );

  test('summary generation negotiates and decodes split NDJSON', () async {
    final client = _testClient(
      MockClient.streaming((request, bytes) async {
        expect(request.method, 'POST');
        expect(request.headers['accept'], 'application/x-ndjson');
        expect(
          request.url.toString(),
          'https://api.mistral.ai$_summaryPath?force=true',
        );
        expect(await bytes.toBytes(), isEmpty);
        final payload = utf8.encode(
          '{"status":"handwritten","translated":false}\r\n'
          '{"content":"café"}\r\n'
          '{"error":"stalled"}\r\n',
        );
        final split = payload.indexOf(0xc3) + 1;
        return http.StreamedResponse(
          Stream.fromIterable([
            payload.sublist(0, split),
            payload.sublist(split),
          ]),
          200,
        );
      }),
    );

    final events = await client.managedSearchIndexes
        .generateSummary(
          indexName: _index,
          language: SummaryLanguage.en,
          force: true,
        )
        .toList();
    expect(events, const [
      SummaryStreamMetadata(
        status: SummaryStatus.handwritten,
        translated: false,
      ),
      SummaryStreamChunk(content: 'café'),
      SummaryStreamError(error: 'stalled'),
    ]);
  });

  test(
    'abort detaches a stalled summary without closing the shared client',
    () async {
      final started = Completer<void>();
      final cancelled = Completer<void>();
      final response = StreamController<List<int>>(
        onListen: started.complete,
        onCancel: cancelled.complete,
      );
      addTearDown(response.close);
      final client = _testClient(
        MockClient.streaming((request, _) async {
          if (request.method == 'GET') {
            return http.StreamedResponse(
              Stream.value(utf8.encode(jsonEncode(_indexPayload))),
              200,
            );
          }
          return http.StreamedResponse(response.stream, 200);
        }),
      );
      final abort = Completer<void>();
      final stream = client.managedSearchIndexes
          .generateSummary(
            indexName: _index,
            language: SummaryLanguage.en,
            abortTrigger: abort.future,
          )
          .toList();
      final aborted = expectLater(stream, throwsA(isA<AbortedException>()));
      await started.future;
      abort.complete();
      await aborted;
      await cancelled.future.timeout(const Duration(seconds: 2));
      expect(
        (await client.managedSearchIndexes.get(indexName: _index)).name,
        _index,
      );
    },
  );
}
