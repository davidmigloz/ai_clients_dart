import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _versions = [
  'web_fetch_20250910',
  'web_fetch_20260209',
  'web_fetch_20260309',
  'web_fetch_20260318',
];
const Map<String, Object> _filters = {
  'user_input': {'type': 'none'},
  'client_tool_results': {
    'type': 'except',
    'tools': [
      {'type': 'tool_reference', 'name': 'run_code'},
    ],
  },
  'server_tool_results': {
    'type': 'only',
    'tools': [
      {'type': 'tool_reference', 'name': 'web_search'},
    ],
  },
};

Map<String, Object> _result(String code) => {
  'type': 'web_fetch_tool_result',
  'tool_use_id': 'srvtoolu_fixture',
  'content': {'type': 'web_fetch_tool_result_error', 'error_code': code},
};

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;
  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  for (final version in _versions) {
    test(
      'writes tagged URL sources with $version through create and countTokens',
      () async {
        final names = ['run_code'];
        final sources = WebFetchUrlSources(
          userInput: WebFetchUrlSourcePolicy.none,
          clientToolResults: WebFetchUrlToolFilter.except(names),
          serverToolResults: WebFetchUrlToolFilter.only(const ['web_search']),
        );
        names.add('not_in_frozen_filter');
        final tool =
            BuiltInTool.webFetch(type: version, urlSources: sources)
                as WebFetchTool;
        final wireTool = {
          'type': version,
          'name': 'web_fetch',
          'url_sources': _filters,
        };
        final restored = BuiltInTool.fromJson(wireTool);
        expect(restored, tool);
        expect(restored.hashCode, tool.hashCode);
        expect(tool.toJson(), wireTool);
        expect(tool.copyWith().urlSources, sources);
        expect(
          tool.copyWith(urlSources: null).toJson(),
          isNot(contains('url_sources')),
        );
        expect(
          tool.copyWith(allowedDomains: []).toJson()['allowed_domains'],
          isEmpty,
        );
        expect(
          sources.copyWith(serverToolResults: null).toJson(),
          isNot(contains('server_tool_results')),
        );

        transport
          ..queueJsonResponse(MockResponses.message())
          ..queueJsonResponse({'input_tokens': 3});
        final request = MessageCreateRequest(
          model: 'claude-sonnet-5-5',
          maxTokens: 64,
          messages: [InputMessage.user('Find the release notes')],
          tools: [
            ToolDefinition.builtIn(tool),
            ToolDefinition.builtIn(BuiltInTool.webSearch()),
            ToolDefinition.custom(
              const Tool(name: 'run_code', inputSchema: InputSchema()),
            ),
          ],
        );
        await client.messages.create(request);
        await client.messages.countTokens(
          TokenCountRequest.fromMessageCreateRequest(request),
        );
        for (final sent in transport.requests) {
          expect(sent.headers['anthropic-beta'], isNull);
          expect((_body(sent)['tools'] as List<Object?>).first, wireTool);
        }
      },
    );
  }

  test(
    'Messages source filters reject Managed Agents shorthand and invalid server tools',
    () {
      expect(
        () => WebFetchUrlSources.fromJson(const {'user_input': 'none'}),
        throwsFormatException,
      );
      expect(
        () => WebFetchUrlSources.fromJson(const {
          'user_input': {'type': 'except', 'tools': <Object?>[]},
        }),
        throwsFormatException,
      );
      expect(
        () => WebFetchUrlSources.fromJson(const {
          'client_tool_results': {
            'type': 'only',
            'tools': ['run_code'],
          },
        }),
        throwsFormatException,
      );
      expect(
        () => WebFetchUrlSources(
          serverToolResults: WebFetchUrlToolFilter.only(const [
            'code_execution',
          ]),
        ).toJson(),
        throwsArgumentError,
      );
      expect(
        const WebFetchUrlSources(
          userInput: WebFetchUrlSourcePolicy.all,
          clientToolResults: WebFetchUrlToolFilter.none(),
        ).toJson(),
        {
          'user_input': {'type': 'all'},
          'client_tool_results': {'type': 'none'},
        },
      );
    },
  );

  for (final streaming in [false, true]) {
    test(
      'parses and replays content_too_large and future codes (SSE=$streaming)',
      () async {
        final blocks = [
          _result('content_too_large'),
          _result('future_error_code'),
        ];
        final response = MockResponses.message()..['content'] = blocks;
        if (streaming) {
          transport.queueStreamingResponse([
            {
              'type': 'message_start',
              'message': {
                ...response,
                'content': <Object>[],
                'stop_reason': null,
              },
            },
            for (final (index, block) in blocks.indexed) ...[
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
        final request = MessageCreateRequest(
          model: 'claude-sonnet-5-5',
          maxTokens: 64,
          messages: [InputMessage.user('Read this document')],
          tools: [ToolDefinition.builtIn(BuiltInTool.webFetch())],
        );
        final message = streaming
            ? await client.messages.createStream(request).finalMessage()
            : await client.messages.create(request);
        final oversized = message.content.first as WebFetchToolResultBlock;
        expect(
          oversized.errorCode,
          WebFetchToolResultErrorCode.contentTooLarge,
        );
        expect(oversized.rawErrorCode, 'content_too_large');
        final future = message.content.last as WebFetchToolResultBlock;
        expect(future.errorCode, WebFetchToolResultErrorCode.unknown);
        expect(future.rawErrorCode, 'future_error_code');
        final assistant = message.toInputMessage();
        final serialized = assistant.toJson();
        expect(serialized['content'], blocks);
        final replay =
            InputContentBlock.fromJson(blocks.last)
                as WebFetchToolResultInputBlock;
        expect(replay.errorCode, WebFetchToolResultErrorCode.unknown);
        expect(replay.rawErrorCode, 'future_error_code');
        await client.messages.create(
          request.copyWith(
            messages: [
              ...request.messages,
              assistant,
              InputMessage.user('Summarize the result'),
            ],
          ),
        );
        final sent =
            (_body(transport.requests.last)['messages'] as List<Object?>)[1]!
                as Map<String, dynamic>;
        expect(sent['content'], blocks);
      },
    );
  }
}
