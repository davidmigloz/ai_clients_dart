import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

/// Fixture helpers for memory-store responses.
class _MemoryStoreFixtures {
  _MemoryStoreFixtures._();

  static Map<String, dynamic> store({
    String id = 'memstore_test123',
    String name = 'Test Store',
    String? archivedAt,
  }) {
    return {
      'type': 'memory_store',
      'id': id,
      'name': name,
      'description': 'A test memory store',
      'metadata': <String, String>{'team': 'platform'},
      'created_at': '2026-04-25T00:00:00Z',
      'updated_at': '2026-04-25T00:00:00Z',
      'archived_at': ?archivedAt,
    };
  }

  static Map<String, dynamic> memory({
    String id = 'mem_test123',
    String storeId = 'memstore_test123',
    String path = '/note.md',
    String? content = 'hello',
  }) {
    return {
      'type': 'memory',
      'id': id,
      'memory_store_id': storeId,
      'path': path,
      'content': ?content,
      'content_size_bytes': (content ?? '').length,
      'content_sha256':
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      'memory_version_id': 'memver_test123',
      'created_at': '2026-04-25T00:00:00Z',
      'updated_at': '2026-04-25T00:00:00Z',
    };
  }

  static Map<String, dynamic> memoryVersion({
    String id = 'memver_test123',
    String storeId = 'memstore_test123',
    String memoryId = 'mem_test123',
    String operation = 'created',
  }) {
    return {
      'type': 'memory_version',
      'id': id,
      'memory_store_id': storeId,
      'memory_id': memoryId,
      'path': '/note.md',
      'content': 'hello',
      'content_size_bytes': 5,
      'content_sha256': 'abc123',
      'operation': operation,
      'created_at': '2026-04-25T00:00:00Z',
      'created_by': {'type': 'api_actor', 'api_key_id': 'apikey_test'},
    };
  }
}

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('MemoryStoresResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(_MemoryStoreFixtures.store());

      final store = await client.memoryStores.create(
        CreateMemoryStoreParams(
          name: 'Test Store',
          description: 'A test memory store',
          metadata: const {'team': 'platform'},
        ),
      );

      expect(store.id, 'memstore_test123');
      expect(store.name, 'Test Store');
      expect(store.description, 'A test memory store');
      expect(store.metadata?['team'], 'platform');
      expect(store.archivedAt, isNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      expect(request.headers['x-api-key'], 'test-api-key');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['name'], 'Test Store');
      expect(body['description'], 'A test memory store');
      expect(body['metadata'], {'team': 'platform'});
    });

    test('list sends correct request with all query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_MemoryStoreFixtures.store()],
        'next_page': 'cursor123',
      });

      final response = await client.memoryStores.list(
        limit: 25,
        page: 'prev_cursor',
        includeArchived: true,
        createdAtGte: '2026-04-01T00:00:00Z',
        createdAtLte: '2026-04-30T00:00:00Z',
      );

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'memstore_test123');
      expect(response.nextPage, 'cursor123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '25');
      expect(request.url.queryParameters['page'], 'prev_cursor');
      expect(request.url.queryParameters['include_archived'], 'true');
      expect(
        request.url.queryParameters['created_at[gte]'],
        '2026-04-01T00:00:00Z',
      );
      expect(
        request.url.queryParameters['created_at[lte]'],
        '2026-04-30T00:00:00Z',
      );
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(_MemoryStoreFixtures.store());

      final store = await client.memoryStores.retrieve('memstore_test123');

      expect(store.id, 'memstore_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores/memstore_test123');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('update sends patch body and parses response', () async {
      mockHttpClient.queueJsonResponse(
        _MemoryStoreFixtures.store(name: 'Renamed'),
      );

      final store = await client.memoryStores.update(
        'memstore_test123',
        const UpdateMemoryStoreParams(
          name: 'Renamed',
          metadata: <String, String?>{'team': null, 'env': 'prod'},
        ),
      );

      expect(store.name, 'Renamed');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores/memstore_test123');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['name'], 'Renamed');
      // Patch with explicit null for delete + non-null upsert.
      expect(body['metadata'], {'team': null, 'env': 'prod'});
      // description was not provided → key omitted.
      expect(body.containsKey('description'), isFalse);
    });

    test('delete sends correct request and parses deleted response', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'memory_store_deleted',
        'id': 'memstore_test123',
      });

      final deleted = await client.memoryStores.delete('memstore_test123');

      expect(deleted.id, 'memstore_test123');
      expect(deleted.type, 'memory_store_deleted');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores/memstore_test123');
      expect(request.method, 'DELETE');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('archive sends empty-body POST and parses response', () async {
      mockHttpClient.queueJsonResponse(
        _MemoryStoreFixtures.store(archivedAt: '2026-04-25T12:00:00Z'),
      );

      final store = await client.memoryStores.archive('memstore_test123');

      expect(store.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores/memstore_test123/archive');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });
  });

  group('MemoriesResource', () {
    test('create sends correct request and view query', () async {
      mockHttpClient.queueJsonResponse(_MemoryStoreFixtures.memory());

      final memory = await client.memoryStores
          .memories('memstore_test123')
          .create(
            const CreateMemoryParams(path: '/note.md', content: 'hello'),
            view: MemoryView.full,
          );

      expect(memory.id, 'mem_test123');
      expect(memory.path, '/note.md');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores/memstore_test123/memories');
      expect(request.method, 'POST');
      expect(request.url.queryParameters['view'], 'full');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['path'], '/note.md');
      expect(body['content'], 'hello');
    });

    test('list sends all query params and parses sealed list items', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          _MemoryStoreFixtures.memory(),
          {'type': 'memory_prefix', 'path': '/sub/'},
          {'type': 'something_new', 'foo': 'bar'},
        ],
        'next_page': null,
      });

      final response = await client.memoryStores
          .memories('memstore_test123')
          .list(
            pathPrefix: '/sub',
            depth: 2,
            orderBy: 'path',
            order: ListOrder.asc,
            limit: 50,
            page: 'pg',
            view: MemoryView.basic,
          );

      expect(response.data, hasLength(3));
      expect(response.data[0], isA<Memory>());
      expect(response.data[1], isA<MemoryPrefix>());
      expect(response.data[2], isA<UnknownMemoryListItem>());
      expect((response.data[2] as UnknownMemoryListItem).rawJson['foo'], 'bar');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/memory_stores/memstore_test123/memories');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['path_prefix'], '/sub');
      expect(request.url.queryParameters['depth'], '2');
      expect(request.url.queryParameters['order_by'], 'path');
      expect(request.url.queryParameters['order'], 'asc');
      expect(request.url.queryParameters['limit'], '50');
      expect(request.url.queryParameters['page'], 'pg');
      expect(request.url.queryParameters['view'], 'basic');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve sends correct request with view', () async {
      mockHttpClient.queueJsonResponse(_MemoryStoreFixtures.memory());

      final memory = await client.memoryStores
          .memories('memstore_test123')
          .retrieve('mem_test123', view: MemoryView.full);

      expect(memory.id, 'mem_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/memory_stores/memstore_test123/memories/mem_test123',
      );
      expect(request.method, 'GET');
      expect(request.url.queryParameters['view'], 'full');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('update sends body with sealed precondition', () async {
      mockHttpClient.queueJsonResponse(_MemoryStoreFixtures.memory());

      await client.memoryStores
          .memories('memstore_test123')
          .update(
            'mem_test123',
            const UpdateMemoryParams(
              content: 'goodbye',
              precondition: ContentSha256Precondition(contentSha256: 'abc'),
            ),
          );

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/memory_stores/memstore_test123/memories/mem_test123',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['content'], 'goodbye');
      expect(body['precondition'], {
        'type': 'content_sha256',
        'content_sha256': 'abc',
      });
      // path was unset → key omitted.
      expect(body.containsKey('path'), isFalse);
    });

    test('delete sends DELETE with optional sha256 query param', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'memory_deleted',
        'id': 'mem_test123',
      });

      final deleted = await client.memoryStores
          .memories('memstore_test123')
          .delete('mem_test123', expectedContentSha256: 'sha-abc');

      expect(deleted.id, 'mem_test123');
      expect(deleted.type, 'memory_deleted');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/memory_stores/memstore_test123/memories/mem_test123',
      );
      expect(request.method, 'DELETE');
      expect(request.url.queryParameters['expected_content_sha256'], 'sha-abc');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });
  });

  group('MemoryVersionsResource', () {
    test('list sends all query params and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_MemoryStoreFixtures.memoryVersion()],
        'next_page': null,
      });

      final response = await client.memoryStores
          .memoryVersions('memstore_test123')
          .list(
            memoryId: 'mem_test123',
            sessionId: 'session_x',
            apiKeyId: 'apikey_y',
            operation: MemoryVersionOperation.modified,
            createdAtGte: '2026-04-01T00:00:00Z',
            createdAtLte: '2026-04-30T00:00:00Z',
            limit: 5,
            page: 'pg',
            view: MemoryView.full,
          );

      expect(response.data, hasLength(1));
      final v = response.data.first;
      expect(v.id, 'memver_test123');
      expect(v.operation, MemoryVersionOperation.created);
      expect(v.createdBy, isA<ApiActor>());
      expect((v.createdBy! as ApiActor).apiKeyId, 'apikey_test');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/memory_stores/memstore_test123/memory_versions',
      );
      expect(request.method, 'GET');
      expect(request.url.queryParameters['memory_id'], 'mem_test123');
      expect(request.url.queryParameters['session_id'], 'session_x');
      expect(request.url.queryParameters['api_key_id'], 'apikey_y');
      expect(request.url.queryParameters['operation'], 'modified');
      expect(
        request.url.queryParameters['created_at[gte]'],
        '2026-04-01T00:00:00Z',
      );
      expect(
        request.url.queryParameters['created_at[lte]'],
        '2026-04-30T00:00:00Z',
      );
      expect(request.url.queryParameters['limit'], '5');
      expect(request.url.queryParameters['page'], 'pg');
      expect(request.url.queryParameters['view'], 'full');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(_MemoryStoreFixtures.memoryVersion());

      final v = await client.memoryStores
          .memoryVersions('memstore_test123')
          .retrieve('memver_test123', view: MemoryView.basic);

      expect(v.id, 'memver_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/memory_stores/memstore_test123/memory_versions/memver_test123',
      );
      expect(request.method, 'GET');
      expect(request.url.queryParameters['view'], 'basic');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('redact sends empty-body POST to /redact', () async {
      mockHttpClient.queueJsonResponse({
        ..._MemoryStoreFixtures.memoryVersion(),
        'redacted_at': '2026-04-25T12:00:00Z',
        'redacted_by': {'type': 'user_actor', 'user_id': 'usr_x'},
      });

      final v = await client.memoryStores
          .memoryVersions('memstore_test123')
          .redact('memver_test123');

      expect(v.redactedAt, isNotNull);
      expect(v.redactedBy, isA<UserActor>());
      expect((v.redactedBy! as UserActor).userId, 'usr_x');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/memory_stores/memstore_test123/memory_versions/memver_test123/redact',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });
  });
}
