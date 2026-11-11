import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _betas = ['mcp-client-2026-09-15'];
const _serverName = 'lookup';
const _serverToken = 'fixture-mcp-token';
const _server = McpConnectorServer(
  name: _serverName,
  url: 'https://tools.example.invalid/mcp',
  authorizationToken: _serverToken,
);
const Map<String, String> _serverJson = {
  'type': 'url',
  'name': _serverName,
  'url': 'https://tools.example.invalid/mcp',
  'authorization_token': _serverToken,
};
const Map<String, Object> _tool = {
  'name': 'query',
  'description': 'Look up an item',
  'input_schema': {
    'type': 'object',
    'properties': {
      'id': {'type': 'string'},
    },
  },
};
const Map<String, Object> _listing = {
  'type': 'mcp_tool_listing',
  'mcp_server_name': _serverName,
  'tools': [_tool],
};
const Map<String, Object> _mcpResult = {
  'type': 'mcp_tool_result',
  'tool_use_id': 'mcp_tool_fixture',
  'is_error': false,
  'content': [
    {
      'type': 'text',
      'text': 'From MCP',
      'citations': [
        {
          'type': 'char_location',
          'cited_text': 'quote',
          'document_index': 0,
          'document_title': 'Tool output',
          'start_char_index': 0,
          'end_char_index': 5,
          'file_id': 'file_response_only',
        },
      ],
    },
  ],
};
const Map<String, Object> _mcpUse = {
  'type': 'mcp_tool_use',
  'id': 'mcp_tool_fixture',
  'name': 'query',
  'server_name': _serverName,
  'input': {'id': 'item'},
};

MessageCreateRequest _request() => MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 64,
  messages: [InputMessage.user('What can you look up?')],
  mcpServers: const [_server],
  tools: [
    ToolDefinition.builtIn(
      BuiltInTool.mcpConnector(
        serverName: _serverName,
        defaultConfig: const McpConnectorToolSettings(enabled: false),
        configs: const {
          'query': McpConnectorToolSettings(enabled: true, deferLoading: false),
        },
      ),
    ),
  ],
);

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-claude-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test(
    'current connector configuration reaches create and countTokens',
    () async {
      transport
        ..queueJsonResponse(MockResponses.message())
        ..queueJsonResponse({'input_tokens': 7});
      final request = _request();
      await client.messages.create(request, betas: _betas);
      final tokenRequest = TokenCountRequest.fromMessageCreateRequest(request);
      final result = await client.messages.countTokens(
        tokenRequest,
        betas: _betas,
      );
      expect(result.inputTokens, 7);
      expect(transport.requests.map((request) => request.url.path), [
        '/v1/messages',
        '/v1/messages/count_tokens',
      ]);
      for (final sent in transport.requests) {
        expect(sent.headers['anthropic-beta'], _betas.single);
        expect(sent.url.queryParameters, isEmpty);
        final body = _body(sent);
        expect(body['mcp_servers'], [_serverJson]);
        expect(body['tools'], [
          {
            'type': 'mcp_toolset',
            'mcp_server_name': _serverName,
            'default_config': {'enabled': false},
            'configs': {
              'query': {'enabled': true, 'defer_loading': false},
            },
          },
        ]);
      }
      expect(request.toString(), isNot(contains(_serverToken)));
      expect(tokenRequest.toString(), isNot(contains(_serverToken)));
    },
  );

  test('MCP server configuration reaches the batch create path', () async {
    transport.queueJsonResponse(MockResponses.messageBatch());
    const batchBetas = ['message-batches-2024-09-24', ..._betas];
    final batch = await client.messages.batches.create(
      MessageBatchCreateRequest(
        requests: [BatchRequestItem(customId: 'mcp', params: _request())],
      ),
      betas: batchBetas,
    );
    expect(batch.id, isNotEmpty);
    final sent = transport.requests.single;
    expect(sent.url.path, '/v1/messages/batches');
    expect(sent.headers['anthropic-beta'], batchBetas.join(','));
    final body = _body(sent);
    expect(body['requests'], [
      {'custom_id': 'mcp', 'params': _request().toJson()},
    ]);
    expect(jsonEncode(body), contains('mcp_servers'));
  });

  test('copyWith keeps omitted lists and distinguishes empty from null', () {
    final request = _request().copyWith(stopSequences: ['done']);
    expect(request.copyWith().toJson(), request.toJson());
    expect(request.copyWith(tools: []).toJson()['tools'], isEmpty);
    expect(
      request.copyWith(stopSequences: []).toJson()['stop_sequences'],
      isEmpty,
    );
    expect(request.copyWith(tools: null).toJson(), isNot(contains('tools')));
    expect(
      request.copyWith(stopSequences: null).toJson(),
      isNot(contains('stop_sequences')),
    );

    final count = TokenCountRequest.fromMessageCreateRequest(request);
    expect(count.copyWith().toJson(), count.toJson());
    expect(count.copyWith(tools: []).toJson()['tools'], isEmpty);
    expect(count.copyWith(tools: null).toJson(), isNot(contains('tools')));
    expect(const ContextManagementConfig().copyWith(edits: []).edits, isEmpty);
    final response = Message.fromJson(MockResponses.message());
    expect(
      response.copyWith(inputTransformations: []).inputTransformations,
      isEmpty,
    );
    expect(
      () => request.copyWith(tools: ['not a tool definition']),
      throwsA(isA<TypeError>()),
    );
  });

  for (final streamed in [false, true]) {
    test(
      'replays the tool list and request-safe citations (SSE=$streamed)',
      () async {
        final response = MockResponses.message()
          ..['content'] = [_listing, _mcpUse, _mcpResult];
        if (streamed) {
          transport.queueStreamingResponse([
            {
              'type': 'message_start',
              'message': {
                ...response,
                'content': <Object>[],
                'stop_reason': null,
              },
            },
            for (final (index, block) in [
              _listing,
              _mcpUse,
              _mcpResult,
            ].indexed) ...[
              {
                'type': 'content_block_start',
                'index': index,
                'content_block': block,
              },
              {'type': 'content_block_stop', 'index': index},
            ],
            {
              'type': 'message_delta',
              'delta': {'stop_reason': 'end_turn', 'stop_sequence': null},
              'usage': {'output_tokens': 2},
            },
            {'type': 'message_stop'},
          ]);
        } else {
          transport.queueJsonResponse(response);
        }
        transport.queueJsonResponse(MockResponses.message());
        final request = _request();
        final reply = streamed
            ? await client.messages
                  .createStream(request, betas: _betas)
                  .finalMessage()
            : await client.messages.create(request, betas: _betas);
        final listing = reply.content.first as McpToolListingBlock;
        expect(listing.serverName, _serverName);
        expect(listing.tools.single.toJson(), _tool);
        expect(reply.content.last.toJson(), _mcpResult);
        final followUp = request.copyWith(
          messages: [
            ...request.messages,
            reply.toInputMessage(),
            InputMessage.user('Use the lookup tool.'),
          ],
          tools: [
            ToolDefinition.builtIn(
              BuiltInTool.mcpConnector(
                serverName: _serverName,
                tools: listing.tools,
              ),
            ),
          ],
        );
        await client.messages.create(followUp, betas: _betas);
        final sent = transport.requests.last;
        final body = _body(sent);
        expect(sent.headers['anthropic-beta'], _betas.single);
        expect(body['tools'], [
          {
            'type': 'mcp_toolset',
            'mcp_server_name': _serverName,
            'tools': [_tool],
          },
        ]);
        final messages = body['messages'] as List<Object?>;
        final assistant = messages[1]! as Map<String, dynamic>;
        final blocks = assistant['content'] as List<Object?>;
        expect(blocks.first, _listing);
        expect(blocks[1], _mcpUse);
        final serialized = jsonEncode(blocks.last);
        expect(serialized, contains('char_location'));
        expect(serialized, contains('quote'));
        expect(serialized, isNot(contains('file_id')));
      },
    );
  }

  test('copies of connector models clear or retain optional configuration', () {
    expect(_server.copyWith(), _server);
    expect(
      _server.copyWith(authorizationToken: null).toJson(),
      isNot(contains('authorization_token')),
    );
    final listed = McpListedTool.fromJson(_tool);
    expect(listed.copyWith(), listed);
    expect(
      listed.copyWith(description: null).toJson(),
      isNot(contains('description')),
    );
    final toolset = McpConnectorToolset(
      serverName: _serverName,
      tools: [listed],
      configs: const {'query': McpConnectorToolSettings(enabled: true)},
    );
    expect(toolset.copyWith(), toolset);
    expect(toolset.copyWith(configs: {}).toJson()['configs'], isEmpty);
    expect(toolset.copyWith(tools: []).toJson()['tools'], isEmpty);
    expect(toolset.copyWith(tools: null).toJson(), isNot(contains('tools')));
    expect(
      const McpConnectorToolSettings(enabled: true).copyWith(enabled: null),
      const McpConnectorToolSettings(),
    );
  });

  test(
    'DTOs preserve legacy omissions, round trips and nullable copy behavior',
    () {
      final request = _request();
      final parsed = MessageCreateRequest.fromJson(request.toJson());
      expect(parsed, request);
      expect(parsed.hashCode, request.hashCode);
      expect(request.copyWith(mcpServers: []).toJson()['mcp_servers'], isEmpty);
      expect(
        request.copyWith(mcpServers: null).toJson(),
        isNot(contains('mcp_servers')),
      );
      final tokenRequest = TokenCountRequest.fromMessageCreateRequest(request);
      final parsedCount = TokenCountRequest.fromJson(tokenRequest.toJson());
      expect(parsedCount, tokenRequest);
      expect(parsedCount.hashCode, tokenRequest.hashCode);
      expect(
        tokenRequest.copyWith(mcpServers: []).toJson()['mcp_servers'],
        isEmpty,
      );
      expect(
        tokenRequest.copyWith(mcpServers: null).toJson(),
        isNot(contains('mcp_servers')),
      );

      final batch = MessageBatchCreateRequest(
        requests: [BatchRequestItem(customId: 'mcp', params: request)],
      );
      expect(MessageBatchCreateRequest.fromJson(batch.toJson()), batch);
      expect(
        () => McpConnectorServer.fromJson(const {
          'type': 'url',
          'name': _serverName,
        }),
        throwsFormatException,
      );
      expect(
        () => ContentBlock.fromJson({..._listing, 'tools': null}),
        throwsFormatException,
      );
    },
  );
}
