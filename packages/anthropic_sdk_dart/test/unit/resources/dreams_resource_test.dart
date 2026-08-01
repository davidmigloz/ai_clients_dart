import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

/// Fixture helpers for dream responses.
class _DreamFixtures {
  _DreamFixtures._();

  static Map<String, dynamic> dream({
    String id = 'dream_test123',
    String status = 'completed',
    String? endedAt = '2026-04-25T01:00:00Z',
    String? archivedAt,
    Map<String, dynamic>? error,
  }) {
    return {
      'type': 'dream',
      'id': id,
      'inputs': [
        {'type': 'memory_store', 'memory_store_id': 'memstore_in123'},
        {
          'type': 'sessions',
          'session_ids': ['session_a', 'session_b'],
        },
      ],
      'outputs': [
        {'type': 'memory_store', 'memory_store_id': 'memstore_out123'},
      ],
      'status': status,
      'created_at': '2026-04-25T00:00:00Z',
      'ended_at': endedAt,
      'archived_at': archivedAt,
      'error': error,
      'model': {'id': 'claude-opus-4-7', 'speed': 'standard'},
      'instructions': 'Consolidate notes about user preferences.',
      'session_id': null,
      'usage': {
        'input_tokens': 100,
        'output_tokens': 50,
        'cache_read_input_tokens': 10,
        'cache_creation_input_tokens': 5,
      },
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

  group('DreamsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(_DreamFixtures.dream());

      final dream = await client.dreams.create(
        const CreateDreamRequest(
          inputs: [
            DreamMemoryStoreInput(memoryStoreId: 'memstore_in123'),
            DreamSessionsInput(sessionIds: ['session_a', 'session_b']),
          ],
          instructions: 'Consolidate notes about user preferences.',
          model: DreamModelParamsId(id: 'claude-opus-4-7'),
        ),
      );

      expect(dream.id, 'dream_test123');
      expect(dream.status, DreamStatus.completed);
      expect(dream.inputs, hasLength(2));
      expect(dream.inputs[0], isA<DreamMemoryStoreInput>());
      expect(dream.inputs[1], isA<DreamSessionsInput>());
      expect(dream.outputs.single, isA<DreamMemoryStoreOutput>());
      expect(dream.model.id, 'claude-opus-4-7');
      expect(dream.model.speed, AgentSpeed.standard);
      expect(dream.usage.inputTokens, 100);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/dreams');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'dreaming-2026-04-21');
      expect(request.headers['x-api-key'], 'test-api-key');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      final inputs = body['inputs'] as List;
      expect(inputs, hasLength(2));
      expect(inputs[0], {
        'type': 'memory_store',
        'memory_store_id': 'memstore_in123',
      });
      expect(inputs[1], {
        'type': 'sessions',
        'session_ids': ['session_a', 'session_b'],
      });
      expect(body['model'], 'claude-opus-4-7');
      expect(body['instructions'], 'Consolidate notes about user preferences.');
    });

    test('create with a model config object sends the object body', () async {
      mockHttpClient.queueJsonResponse(_DreamFixtures.dream());

      await client.dreams.create(
        const CreateDreamRequest(
          inputs: [DreamMemoryStoreInput(memoryStoreId: 'memstore_in123')],
          model: DreamModelConfigParams(
            id: 'claude-opus-4-7',
            speed: AgentSpeed.fast,
          ),
        ),
      );

      final request = mockHttpClient.lastRequest!;
      expect(request.headers['anthropic-beta'], 'dreaming-2026-04-21');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['model'], {'id': 'claude-opus-4-7', 'speed': 'fast'});
      expect(body.containsKey('instructions'), isFalse);
    });

    test('list sends correct request with all query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_DreamFixtures.dream()],
        'next_page': 'cursor123',
      });

      final response = await client.dreams.list(
        limit: 25,
        page: 'prev_cursor',
        includeArchived: true,
        statuses: [DreamStatus.completed, DreamStatus.failed],
        createdAtGt: '2026-04-01T00:00:00Z',
        createdAtLt: '2026-04-30T00:00:00Z',
      );

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'dream_test123');
      expect(response.nextPage, 'cursor123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/dreams');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '25');
      expect(request.url.queryParameters['page'], 'prev_cursor');
      expect(request.url.queryParameters['include_archived'], 'true');
      expect(request.url.queryParametersAll['statuses[]'], [
        'completed',
        'failed',
      ]);
      expect(
        request.url.queryParameters['created_at[gt]'],
        '2026-04-01T00:00:00Z',
      );
      expect(
        request.url.queryParameters['created_at[lt]'],
        '2026-04-30T00:00:00Z',
      );
      expect(request.headers['anthropic-beta'], 'dreaming-2026-04-21');
    });

    test('list parses an unknown status as a fallback', () async {
      mockHttpClient.queueJsonResponse({
        'data': [_DreamFixtures.dream(status: 'something_new')],
        'next_page': null,
      });

      final response = await client.dreams.list();

      expect(response.data.single.status, DreamStatus.unknown);
      expect(
        mockHttpClient.lastRequest!.headers['anthropic-beta'],
        'dreaming-2026-04-21',
      );
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(_DreamFixtures.dream());

      final dream = await client.dreams.retrieve('dream_test123');

      expect(dream.id, 'dream_test123');

      final req = mockHttpClient.lastRequest!;
      expect(req.url.path, '/v1/dreams/dream_test123');
      expect(req.method, 'GET');
      expect(req.headers['anthropic-beta'], 'dreaming-2026-04-21');
    });

    test('archive sends empty-body POST and parses response', () async {
      mockHttpClient.queueJsonResponse(
        _DreamFixtures.dream(archivedAt: '2026-04-25T12:00:00Z'),
      );

      final dream = await client.dreams.archive('dream_test123');

      expect(dream.archivedAt, isNotNull);

      final req = mockHttpClient.lastRequest!;
      expect(req.url.path, '/v1/dreams/dream_test123/archive');
      expect(req.method, 'POST');
      expect(req.headers['anthropic-beta'], 'dreaming-2026-04-21');

      final body = jsonDecode((req as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });

    test('cancel sends empty-body POST and parses response', () async {
      mockHttpClient.queueJsonResponse(
        _DreamFixtures.dream(status: 'canceled', endedAt: null),
      );

      final dream = await client.dreams.cancel('dream_test123');

      expect(dream.status, DreamStatus.canceled);
      expect(dream.endedAt, isNull);

      final req = mockHttpClient.lastRequest!;
      expect(req.url.path, '/v1/dreams/dream_test123/cancel');
      expect(req.method, 'POST');
      expect(req.headers['anthropic-beta'], 'dreaming-2026-04-21');

      final body = jsonDecode((req as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });
  });
}
