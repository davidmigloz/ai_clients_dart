import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _newVersion = '2026-10-21';
const _oldVersion = '2023-06-01';
const _model = 'claude-sonnet-4-6';
const _citation = CharLocationInputCitation(
  citedText: 'source text',
  documentIndex: 0,
  documentTitle: null,
  startCharIndex: 0,
  endCharIndex: 11,
);
const _citedText = TextInputBlock('source text', citations: [_citation]);
const _document = DocumentInputBlock(
  PlainTextSource('source text'),
  citations: RequestCitationsConfig(enabled: true),
);
const _searchResult = SearchResultInputBlock(
  source: 'https://example.com/source',
  title: 'Source',
  content: [_citedText],
);

void main() {
  late MockHttpClient transport;

  AnthropicClient makeClient({
    String? apiVersion,
    Map<String, String> defaultHeaders = const {},
  }) {
    final config = const AnthropicConfig(
      authProvider: ApiKeyProvider('test-api-key'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ).copyWith(apiVersion: apiVersion, defaultHeaders: defaultHeaders);
    final client = AnthropicClient(config: config, httpClient: transport);
    addTearDown(client.close);
    return client;
  }

  setUp(() => transport = MockHttpClient());

  test('uses the new API version on every Messages path', () async {
    transport
      ..queueJsonResponse(MockResponses.message())
      ..queueStreamingResponse(MockResponses.streamingEvents())
      ..queueJsonResponse(MockResponses.tokenCount(inputTokens: 12))
      ..queueJsonResponse(MockResponses.messageBatch());
    final client = makeClient();
    final message = _message([InputMessage.user('Hello')]);

    await client.messages.create(message);
    final events = await client.messages.createStream(message).toList();
    expect(events.last, isA<MessageStopEvent>());
    await client.messages.countTokens(
      TokenCountRequest.fromMessageCreateRequest(message),
    );
    await client.messages.batches.create(_batch(message));

    expect(transport.requests.map((request) => request.url.path), [
      '/v1/messages',
      '/v1/messages',
      '/v1/messages/count_tokens',
      '/v1/messages/batches',
    ]);
    for (final request in transport.requests) {
      expect(request.method, 'POST');
      expect(request.headers['anthropic-version'], _newVersion);
      expect(request.headers['x-api-key'], 'test-api-key');
      expect(request.headers, isNot(contains('authorization')));
    }
  });

  group('rejects sampling parameters by presence on the new version', () {
    const samplingOptions = {'temperature': 1.0, 'top_p': 1.0, 'top_k': 0};
    for (final MapEntry(:key, :value) in samplingOptions.entries) {
      final request = MessageCreateRequest.fromJson({
        'model': _model,
        'max_tokens': 128,
        'messages': const [
          {'role': 'user', 'content': 'Hello'},
        ],
        key: value,
      });

      test('create rejects $key', () async {
        final client = makeClient();
        await expectLater(
          client.messages.create(request),
          throwsA(_validationMentions(key)),
        );
        expect(transport.requests, isEmpty);
      });

      test('stream reports $key through an error event and closes', () async {
        final client = makeClient();
        final stream = client.messages.createStream(request);
        await expectLater(
          stream,
          emitsInOrder([emitsError(_validationMentions(key)), emitsDone]),
        );
        expect(transport.requests, isEmpty);
      });

      test('batch rejects $key even when the first item is valid', () async {
        final client = makeClient();
        await expectLater(
          client.messages.batches.create(
            _batch(request, includeValidFirstItem: true),
          ),
          throwsA(_validationMentions(key)),
        );
        expect(transport.requests, isEmpty);
      });
    }
  });

  final invalidMessages = {
    'direct assistant document': (
      InputMessage.assistantBlocks(const [_document]),
      'document',
    ),
    'direct user text citations': (
      InputMessage.userBlocks(const [_citedText]),
      'citations',
    ),
    'user search result text citations': (
      InputMessage.userBlocks(const [_searchResult]),
      'citations',
    ),
    'user tool result with search result text citations': (
      InputMessage.userBlocks([
        InputContentBlock.toolResult(
          toolUseId: 'toolu_search',
          content: [ToolResultContent.searchResult(_searchResult)],
        ),
      ]),
      'citations',
    ),
    'user MCP tool result text citations': (
      InputMessage.userBlocks([
        MCPToolResultInputBlock(
          toolUseId: 'mcptoolu_search',
          content: MCPToolResultContent.blocks(const [
            TextBlock(
              text: 'source text',
              citations: [
                CharLocationCitation(
                  citedText: 'source text',
                  documentIndex: 0,
                  startCharIndex: 0,
                  endCharIndex: 11,
                ),
              ],
            ),
          ]),
        ),
      ]),
      'citations',
    ),
    'user document source text citations': (
      InputMessage.userBlocks([
        UnknownInputContentBlock(
          raw: {
            'type': 'document',
            'source': {
              'type': 'content',
              'content': [_citedText.toJson()],
            },
          },
        ),
      ]),
      'citations',
    ),
  };

  for (final MapEntry(key: name, value: (message, field))
      in invalidMessages.entries) {
    test('rejects $name across Messages and Batches entry points', () async {
      final client = makeClient();
      final request = _message([InputMessage.user('Hello'), message]);
      final validation = _validationMentions(field);

      await expectLater(client.messages.create(request), throwsA(validation));
      await expectLater(
        client.messages.createStream(request),
        emitsInOrder([emitsError(validation), emitsDone]),
      );
      await expectLater(
        client.messages.countTokens(
          TokenCountRequest.fromMessageCreateRequest(request),
        ),
        throwsA(validation),
      );
      await expectLater(
        client.messages.batches.create(_batch(request)),
        throwsA(validation),
      );
      expect(transport.requests, isEmpty);
    });
  }

  test(
    'accepts citation configuration and valid history on the new API',
    () async {
      transport.queueJsonResponse(MockResponses.message());
      final client = makeClient();
      final messages = [
        InputMessage.userBlocks(const [
          _document,
          TextInputBlock('Look at this', citations: []),
          SearchResultInputBlock(
            content: [TextInputBlock('snippet', citations: [])],
            source: 'https://example.com/search',
            title: 'Search result',
            citations: RequestCitationsConfig(enabled: true),
          ),
        ]),
        InputMessage.assistantBlocks(const [
          ServerToolUseInputBlock(
            id: 'srvtoolu_fetch',
            name: 'web_fetch',
            input: {'url': 'https://example.com/source'},
          ),
          WebFetchToolResultInputBlock(
            toolUseId: 'srvtoolu_fetch',
            content: {
              'type': 'web_fetch_result',
              'url': 'https://example.com/source',
              'content': {
                'type': 'document',
                'source': {
                  'type': 'text',
                  'media_type': 'text/plain',
                  'data': 'source text',
                },
              },
            },
          ),
          _citedText,
        ]),
        InputMessage.user('Continue'),
      ];

      await client.messages.create(_message(messages));

      final body = _body(transport.lastRequest!);
      expect(
        body['messages'],
        messages.map((message) => message.toJson()).toList(),
      );
    },
  );

  for (final useDefaultHeader in [false, true]) {
    final configuration = useDefaultHeader ? 'mixed-case header' : 'apiVersion';
    test('$configuration opts every entry point into the legacy API', () async {
      transport
        ..queueJsonResponse(MockResponses.message())
        ..queueStreamingResponse(MockResponses.streamingEvents())
        ..queueJsonResponse(MockResponses.tokenCount(inputTokens: 12))
        ..queueJsonResponse(MockResponses.messageBatch());
      final client = makeClient(
        apiVersion: useDefaultHeader ? _newVersion : _oldVersion,
        defaultHeaders: useDefaultHeader
            ? const {'Anthropic-Version': _oldVersion}
            : const {},
      );
      final request = _message([
        InputMessage.userBlocks(const [_citedText, _searchResult]),
        InputMessage.assistantBlocks(const [_document]),
      ]).copyWith(temperature: 0.7, topP: 0.9, topK: 40);

      await client.messages.create(request);
      final streamEvents = await client.messages.createStream(request).toList();
      expect(streamEvents.last, isA<MessageStopEvent>());
      await client.messages.countTokens(
        TokenCountRequest.fromMessageCreateRequest(request),
      );
      await client.messages.batches.create(_batch(request));

      expect(transport.requests, hasLength(4));
      for (final sent in transport.requests) {
        expect(sent.headers['anthropic-version'], _oldVersion);
        expect(sent.headers['x-api-key'], 'test-api-key');
      }
      final bodies = transport.requests.map(_body).toList();
      final requestJson = request.toJson();
      expect(bodies[0], requestJson);
      expect(bodies[1], {...requestJson, 'stream': true});
      expect(bodies[2]['messages'], requestJson['messages']);
      expect(bodies[3]['requests'], [
        {'custom_id': 'candidate', 'params': requestJson},
      ]);
    });
  }

  test(
    'an explicit new version header overrides legacy configuration',
    () async {
      final client = makeClient(
        apiVersion: _oldVersion,
        defaultHeaders: const {'ANTHROPIC-VERSION': _newVersion},
      );
      await expectLater(
        client.messages.create(
          _message([InputMessage.user('Hello')]).copyWith(temperature: 1.0),
        ),
        throwsA(_validationMentions('temperature')),
      );
      expect(transport.requests, isEmpty);
    },
  );
}

MessageCreateRequest _message(List<InputMessage> messages) =>
    MessageCreateRequest(model: _model, maxTokens: 128, messages: messages);

MessageBatchCreateRequest _batch(
  MessageCreateRequest candidate, {
  bool includeValidFirstItem = false,
}) => MessageBatchCreateRequest(
  requests: [
    if (includeValidFirstItem)
      BatchRequestItem(
        customId: 'valid',
        params: _message([InputMessage.user('Hello')]),
      ),
    BatchRequestItem(customId: 'candidate', params: candidate),
  ],
);

Matcher _validationMentions(String field) => isA<ValidationException>().having(
  (error) => error.message,
  'message',
  contains(field),
);

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;
