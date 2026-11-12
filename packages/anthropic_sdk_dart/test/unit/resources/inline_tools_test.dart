import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _betas = ['inline-tools-2026-09-15', 'mcp-client-2026-09-15', 'extra'];
const List<String> _signedBetas = [
  ..._betas,
  'compact-2026-09-04',
  'task-budgets-2026-03-13',
];
const _custom = Tool(
  name: 'lookup',
  description: 'Look up an item',
  inputSchema: InputSchema(
    properties: {
      'item': {'type': 'string'},
    },
    required: ['item'],
  ),
);
const Map<String, Object> _futureTool = {
  'type': 'tool_addition',
  'tool': {
    'type': 'tool_definition',
    'definition': {
      'type': 'future_server_tool',
      'name': 'future',
      'input_schema': {'type': 'object'},
      'new_config': {'marker': 1},
    },
  },
};
const Map<String, Object> _compaction = {
  'type': 'compaction',
  'content': 'Summary',
  'encrypted_content': 'fixture-encrypted',
  'signature': 'fixture-signed',
  'tool_changes': [_futureTool],
};

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

void main() {
  test(
    'creates, counts and streams inline client, server and MCP tools',
    () async {
      final transport = MockHttpClient()
        ..queueJsonResponse(MockResponses.message())
        ..queueJsonResponse(MockResponses.tokenCount())
        ..queueStreamingResponse(MockResponses.streamingEvents());
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final connector = BuiltInTool.mcpConnector(serverName: 'inventory');
      final search = BuiltInTool.webSearch();
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 256,
        messages: [
          InputMessage.user('Find the item'),
          InputMessage.systemBlocks([
            InputContentBlock.toolAddition(
              tool: ToolChangeReference.definition(
                ToolDefinition.custom(_custom),
              ),
            ),
            InputContentBlock.toolAddition(
              tool: ToolChangeReference.definition(
                ToolDefinition.builtIn(search),
              ),
            ),
            InputContentBlock.toolAddition(
              tool: ToolChangeReference.definition(
                ToolDefinition.builtIn(connector),
              ),
            ),
            InputContentBlock.toolRemoval(
              tool: ToolChangeReference.tool('lookup'),
            ),
          ]),
        ],
        mcpServers: const [
          McpConnectorServer(
            name: 'inventory',
            url: 'https://example.invalid/mcp',
          ),
        ],
      );
      await client.messages.create(request, betas: _betas);
      await client.messages.countTokens(
        TokenCountRequest.fromMessageCreateRequest(request),
        betas: _betas,
      );
      await client.messages.createStream(request, betas: _betas).drain<void>();
      expect(transport.requests.map((request) => request.url.path), [
        '/v1/messages',
        '/v1/messages/count_tokens',
        '/v1/messages',
      ]);
      for (final sent in transport.requests) {
        expect(sent.headers['anthropic-beta'], _betas.join(','));
        final body = _body(sent);
        final system =
            (body['messages'] as List<dynamic>)[1] as Map<String, dynamic>;
        expect(system['role'], 'system');
        expect(system['content'], [
          for (final definition in [
            _custom.toJson(),
            search.toJson(),
            connector.toJson(),
          ])
            {
              'type': 'tool_addition',
              'tool': {'type': 'tool_definition', 'definition': definition},
            },
          {
            'type': 'tool_removal',
            'tool': {'type': 'tool_reference', 'name': 'lookup'},
          },
        ]);
      }
    },
  );

  test(
    'future inline tool round-trips in signed response and replay',
    () async {
      final transport = MockHttpClient()
        ..queueJsonResponse({
          ...MockResponses.message(),
          'content': [_compaction],
        })
        ..queueJsonResponse(MockResponses.message());
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 256,
        messages: [InputMessage.user('Summarize')],
      );
      final response = await client.messages.create(
        request,
        betas: _signedBetas,
      );
      final block = response.content.single as CompactionBlock;
      final change = block.toolChangeBlocks!.single;
      final tool = change.tool! as ToolChangeInlineDefinition;
      expect(change.type, 'tool_addition');
      expect(change.toJson(), _futureTool);
      expect(tool.definition, isNull);
      expect(tool.toJson(), _futureTool['tool']);
      expect(tool, ToolChangeReference.fromJson(tool.toJson()));
      expect(
        tool.hashCode,
        ToolChangeReference.fromJson(tool.toJson()).hashCode,
      );
      expect(block.toJson(), _compaction);
      await client.messages.create(
        request.copyWith(
          messages: [
            ...request.messages,
            response.toInputMessage(),
            InputMessage.user('Continue'),
          ],
        ),
        betas: _signedBetas,
      );
      for (final sent in transport.requests) {
        expect(sent.headers['anthropic-beta'], _signedBetas.join(','));
      }
      final messages =
          _body(transport.requests.last)['messages'] as List<dynamic>;
      expect(messages[1], {
        'role': 'assistant',
        'content': [_compaction],
      });
    },
  );

  test(
    'nullable document citation fields survive response and replay',
    () async {
      const variants = [
        {'type': 'char_location', 'start_char_index': 0, 'end_char_index': 5},
        {'type': 'page_location', 'start_page_number': 1, 'end_page_number': 2},
        {
          'type': 'content_block_location',
          'start_block_index': 0,
          'end_block_index': 1,
        },
      ];
      final citations = [
        for (final variant in variants)
          {
            ...variant,
            'cited_text': 'quote',
            'document_index': 0,
            'document_title': null,
            'file_id': null,
          },
      ];
      final transport = MockHttpClient()
        ..queueJsonResponse({
          ...MockResponses.message(),
          'content': [
            {'type': 'text', 'text': 'quote', 'citations': citations},
          ],
        })
        ..queueJsonResponse(MockResponses.message());
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 256,
        messages: [InputMessage.user('Cite the document')],
      );
      final response = await client.messages.create(request);
      expect(response.content.single.toJson()['citations'], citations);
      for (final citation in citations) {
        final present = Citation.fromJson({
          ...citation,
          'document_title': 'Fixture',
          'file_id': 'file_fixture',
        });
        final cleared = switch (present) {
          CharLocationCitation() => present.copyWith(
            documentTitle: null,
            fileId: null,
          ),
          PageLocationCitation() => present.copyWith(
            documentTitle: null,
            fileId: null,
          ),
          ContentBlockLocationCitation() => present.copyWith(
            documentTitle: null,
            fileId: null,
          ),
          _ => throw StateError('Expected a document citation'),
        };
        expect(cleared.toJson(), citation);
      }
      await client.messages.create(
        request.copyWith(
          messages: [
            ...request.messages,
            response.toInputMessage(),
            InputMessage.user('Continue'),
          ],
        ),
      );
      final messages =
          _body(transport.requests.last)['messages'] as List<dynamic>;
      expect(messages[1], {
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': 'quote',
            'citations': [
              for (final citation in citations)
                Map.of(citation)..remove('file_id'),
            ],
          },
        ],
      });
    },
  );

  test('typed inline round-trip and reference-only removal', () {
    final original = ToolChangeReference.definition(
      ToolDefinition.custom(_custom),
    );
    final roundTrip =
        ToolChangeReference.fromJson(original.toJson())
            as ToolChangeInlineDefinition;
    expect(roundTrip.definition, ToolDefinition.custom(_custom));
    expect(roundTrip, original);
    expect(roundTrip.hashCode, original.hashCode);
    expect(
      () => InputContentBlock.toolRemoval(tool: original).toJson(),
      throwsArgumentError,
    );
  });

  test('raw inline removal fails before every Messages dispatch', () async {
    final transport = MockHttpClient();
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    final request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 256,
      messages: [
        InputMessage.user('Use the tool'),
        InputMessage.systemBlocks([
          InputContentBlock.toolRemoval(
            tool: UnknownToolChangeReference(
              rawJson: _futureTool['tool']! as Map<String, dynamic>,
            ),
          ),
        ]),
      ],
    );
    await expectLater(
      client.messages.create(request, betas: _betas),
      throwsArgumentError,
    );
    await expectLater(
      client.messages.countTokens(
        TokenCountRequest.fromMessageCreateRequest(request),
        betas: _betas,
      ),
      throwsArgumentError,
    );
    expect(
      () => client.messages.createStream(request, betas: _betas),
      throwsArgumentError,
    );
    expect(transport.requests, isEmpty);
  });
}
