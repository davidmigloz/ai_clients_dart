import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(authProvider: ApiKeyProvider('test-key')),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test('lists older model responses without new request options', () async {
    transport.queueJsonResponse({
      'data': [_model('claude-opus-4-6')],
      'has_more': false,
      'first_id': 'claude-opus-4-6',
      'last_id': 'claude-opus-4-6',
    });

    final page = await client.models.list();

    expect(page.hasMore, isFalse);
    final model = page.data.single;
    expect(model.id, 'claude-opus-4-6');
    expect(model.line, isNull);
    expect(model.lifecycle, isNull);
    expect(model.deprecatedAt, isNull);
    expect(model.retiresAt, isNull);
    final request = transport.lastRequest!;
    expect(request.method, 'GET');
    expect(request.url.path, '/v1/models');
    expect(request.url.queryParametersAll, isEmpty);
    expect(request.headers['anthropic-beta'], isNull);
    expect(request.headers['anthropic-workspace-id'], isNull);
  });

  test(
    'sends repeated lifecycle filters and both page cursor directions',
    () async {
      const betas = [
        'compact-2026-09-04',
        'thinking-binding-controls-2026-08-01',
      ];
      const workspace = 'wrkspc_test';
      const lifecycle = [ModelLifecycle.active, ModelLifecycle.retired];
      transport
        ..queueJsonResponse({
          'data': [
            {
              ..._model('claude-fable-5-2'),
              'line': 'fable',
              'lifecycle': 'active',
              'deprecated_at': null,
              'retires_at': null,
              'max_input_tokens': 1000000,
              'max_tokens': 128000,
              'capabilities': _capabilities,
              'allowed_fallback_models': ['claude-opus-5-5'],
            },
          ],
          'has_more': true,
          'first_id': 'claude-fable-5-2',
          'last_id': 'claude-fable-5-2',
        })
        ..queueJsonResponse({
          'data': <Map<String, dynamic>>[],
          'has_more': false,
          'first_id': null,
          'last_id': null,
        })
        ..queueJsonResponse({
          'data': <Map<String, dynamic>>[],
          'has_more': false,
          'first_id': null,
          'last_id': null,
        });

      final page = await client.models.list(
        limit: 1,
        lifecycle: lifecycle,
        betas: betas,
        workspaceId: workspace,
      );
      expect(page.hasMore, isTrue);
      final model = page.data.single;
      expect(model.line, 'fable');
      expect(model.lifecycle, ModelLifecycle.active);
      expect(model.maxInputTokens, 1000000);
      expect(model.allowedFallbackModels, ['claude-opus-5-5']);
      expect(model.capabilities!.compaction!.summarize.supported, isTrue);
      expect(
        model.capabilities!.thinking.types.betweenTools!.supported,
        isTrue,
      );
      expect(model.capabilities!.serverTools!.webSearch.supported, isTrue);
      expect(model.capabilities!.serverTools!.codeExecution.supported, isFalse);

      final next = await client.models.list(
        afterId: page.lastId,
        limit: 1,
        lifecycle: lifecycle,
        betas: betas,
        workspaceId: workspace,
      );
      expect(next.data, isEmpty);
      expect(next.hasMore, isFalse);
      expect(next.lastId, isNull);

      final previous = await client.models.list(
        beforeId: page.firstId,
        limit: 1,
        lifecycle: lifecycle,
        betas: betas,
        workspaceId: workspace,
      );
      expect(previous.data, isEmpty);
      expect(previous.hasMore, isFalse);
      expect(previous.firstId, isNull);

      expect(transport.requests, hasLength(3));
      for (final request in transport.requests) {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/models');
        expect(request.headers['anthropic-beta'], betas.join(','));
        expect(request.headers['anthropic-workspace-id'], workspace);
        expect(request.headers['x-api-key'], 'test-key');
      }
      const filters = {
        'limit': ['1'],
        'lifecycle[]': ['active', 'retired'],
      };
      expect(transport.requests[0].url.queryParametersAll, filters);
      expect(transport.requests[1].url.queryParametersAll, {
        ...filters,
        'after_id': ['claude-fable-5-2'],
      });
      expect(transport.requests[2].url.queryParametersAll, {
        ...filters,
        'before_id': ['claude-fable-5-2'],
      });
    },
  );

  test('retrieves an arbitrary model ID on the beta route', () async {
    const modelId = 'custom/team:claude+5?alias=2';
    transport.queueJsonResponse({
      ..._model(modelId),
      'line': 'future_line',
      'lifecycle': 'future_stage',
      'deprecated_at': null,
      'retires_at': null,
      'capabilities': _capabilities,
      'max_input_tokens': null,
      'max_tokens': null,
      'allowed_fallback_models': null,
    });
    final routedClient = AnthropicClient(
      config: const AnthropicConfig(
        defaultHeaders: {'Anthropic-Workspace-ID': 'wrkspc_default'},
      ),
      httpClient: transport,
    );
    addTearDown(routedClient.close);

    final model = await routedClient.models.retrieve(
      modelId,
      betas: const ['compact-2026-09-04'],
      workspaceId: 'wrkspc_override',
    );

    expect(model.id, modelId);
    expect(model.toJson()['lifecycle'], 'future_stage');
    expect(model.toJson()['line'], 'future_line');
    expect(model.capabilities!.compaction!.supported, isTrue);
    final request = transport.lastRequest!;
    expect(request.method, 'GET');
    expect(request.url.pathSegments, ['v1', 'models', modelId]);
    expect(request.url.queryParametersAll, isEmpty);
    expect(request.headers['anthropic-beta'], 'compact-2026-09-04');
    expect(request.headers['anthropic-workspace-id'], 'wrkspc_override');
    expect(
      request.headers.keys.where(
        (key) => key.toLowerCase() == 'anthropic-workspace-id',
      ),
      hasLength(1),
    );
  });

  test('rejects empty and dot path identifiers before transport', () async {
    for (final id in ['', '.', '..', ';suffix', '..;suffix']) {
      await expectLater(client.models.retrieve(id), throwsArgumentError);
    }
    expect(transport.requests, isEmpty);
  });

  test('between-tools thinking reaches each Messages request path', () async {
    transport
      ..queueJsonResponse(MockResponses.message())
      ..queueStreamingResponse(MockResponses.streamingEvents())
      ..queueJsonResponse(MockResponses.tokenCount(inputTokens: 12))
      ..queueJsonResponse(MockResponses.messageBatch());
    final request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 128,
      messages: [InputMessage.user('Hello')],
      thinking: const ThinkingConfig.betweenTools(),
    );

    await client.messages.create(request);
    final events = await client.messages.createStream(request).toList();
    expect(events.last, isA<MessageStopEvent>());
    await client.messages.countTokens(
      TokenCountRequest.fromMessageCreateRequest(request),
    );
    await client.messages.batches.create(
      MessageBatchCreateRequest(
        requests: [BatchRequestItem(customId: 'one', params: request)],
      ),
    );

    expect(transport.requests, hasLength(4));
    final bodies = transport.requests.map(_body).toList();
    for (final body in bodies.take(3)) {
      expect(body['thinking'], {'type': 'between_tools'});
    }
    expect(bodies.last['requests'], [
      {
        'custom_id': 'one',
        'params': {
          'model': 'claude-sonnet-5-5',
          'max_tokens': 128,
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
          'thinking': {'type': 'between_tools'},
        },
      },
    ]);
  });
}

Map<String, dynamic> _model(String id) => {
  'id': id,
  'type': 'model',
  'display_name': 'Claude',
  'created_at': '2026-09-29T00:00:00Z',
};

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

const _supported = {'supported': true};
const _unsupported = {'supported': false};
const Map<String, dynamic> _capabilities = {
  'batch': _supported,
  'citations': _supported,
  'code_execution': _supported,
  'context_management': {
    'supported': true,
    'clear_thinking_20251015': null,
    'clear_tool_uses_20250919': null,
    'compact_20260112': null,
  },
  'effort': {
    'supported': true,
    'high': _supported,
    'low': _supported,
    'max': _supported,
    'medium': _supported,
    'xhigh': _unsupported,
  },
  'image_input': _supported,
  'pdf_input': _supported,
  'structured_outputs': _supported,
  'thinking': {
    'supported': true,
    'types': {
      'adaptive': _supported,
      'enabled': _unsupported,
      'between_tools': _supported,
      'disabled': _unsupported,
    },
  },
  'server_tools': {
    'supported': true,
    'code_execution': _unsupported,
    'web_search': _supported,
  },
  'compaction': {'supported': true, 'summarize': _supported},
};
