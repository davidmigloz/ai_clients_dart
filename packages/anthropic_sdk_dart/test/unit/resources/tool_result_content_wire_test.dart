import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _citation = <String, Object?>{
  'type': 'char_location',
  'cited_text': 'Excerpt',
  'document_index': 0,
  'document_title': null,
  'start_char_index': 0,
  'end_char_index': 7,
};
const _cacheControl = {'type': 'ephemeral', 'ttl': '1h'};
const _text = <String, Object?>{
  'type': 'text',
  'text': 'Excerpt',
  'citations': [_citation],
  'cache_control': _cacheControl,
};
const _image = <String, Object?>{
  'type': 'image',
  'source': {'type': 'url', 'url': 'https://fixture.invalid/image.png'},
  'cache_control': _cacheControl,
};

enum _Endpoint { create, withResponse, count, stream, batch }

void main() {
  test('public constructors expose and compare full tool result blocks', () {
    final cacheControl = CacheControlEphemeral.fromJson(_cacheControl);
    final text = ToolResultContent.text(
      'Excerpt',
      citations: [InputCitation.fromJson(_citation)],
      cacheControl: cacheControl,
    );
    final image = ToolResultContent.image(
      ImageSource.fromJson(_image['source']! as Map<String, dynamic>),
      cacheControl: cacheControl,
    );
    for (final (block, json) in [(text, _text), (image, _image)]) {
      final decoded = ToolResultContent.fromJson(json);
      expect(block.toJson(), json);
      expect(block, decoded);
      expect(block.hashCode, decoded.hashCode);
    }
    expect(text, isNot(const ToolResultTextContent('Excerpt')));
    expect(
      image,
      isNot(ToolResultImageContent((image as ToolResultImageContent).source)),
    );
  });

  for (final endpoint in _Endpoint.values) {
    for (final beta in [false, true]) {
      test(
        'nested tool result fields through ${endpoint.name} (beta=$beta)',
        () async {
          final transport = MockHttpClient();
          final current = AnthropicClient(httpClient: transport);
          final legacy = AnthropicClient(
            config: const AnthropicConfig(
              apiVersion: AnthropicConfig.legacyApiVersion,
            ),
            httpClient: transport,
          );
          addTearDown(current.close);
          addTearDown(legacy.close);
          final betaHeader = endpoint == _Endpoint.batch
              ? 'message-batches-2024-09-24'
              : 'mcp-client-2026-09-15';
          final betas = [if (beta) betaHeader];
          final request = _request(_text);

          _queueResponse(transport, endpoint);
          await _send(legacy, endpoint, request, betas);
          final legacyRequest = transport.requests.single as http.Request;
          expect(legacyRequest.headers['anthropic-version'], '2023-06-01');
          expect(
            legacyRequest.headers['anthropic-beta'],
            beta ? betas.single : isNull,
          );
          expect(_toolResultContent(legacyRequest, endpoint), [_text, _image]);

          final prefix = endpoint == _Endpoint.batch
              ? 'requests[0].params.'
              : '';
          await expectLater(
            _send(current, endpoint, request, betas),
            throwsA(
              isA<ValidationException>().having(
                (error) => error.fieldErrors.keys,
                'nested citation field',
                contains(
                  '${prefix}messages[2].content[0].content[0].citations',
                ),
              ),
            ),
          );
          expect(transport.requests, hasLength(1));

          final emptyCitations = {..._text, 'citations': <Object>[]};
          _queueResponse(transport, endpoint);
          await _send(current, endpoint, _request(emptyCitations), betas);
          final currentRequest = transport.requests.last as http.Request;
          expect(currentRequest.headers['anthropic-version'], '2026-10-21');
          expect(_toolResultContent(currentRequest, endpoint), [
            emptyCitations,
            _image,
          ]);
          expect(transport.requests, hasLength(2));
        },
      );
    }
  }
}

MessageCreateRequest _request(Map<String, Object?> text) =>
    MessageCreateRequest.fromJson({
      'model': 'claude-sonnet-4-6',
      'max_tokens': 64,
      'messages': [
        const {'role': 'user', 'content': 'Call the tool'},
        const {
          'role': 'assistant',
          'content': [
            {
              'type': 'tool_use',
              'id': 'toolu_fixture',
              'name': 'lookup',
              'input': <String, Object?>{},
            },
          ],
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'tool_result',
              'tool_use_id': 'toolu_fixture',
              'content': [text, _image],
            },
          ],
        },
      ],
    });

Future<Object?> _send(
  AnthropicClient client,
  _Endpoint endpoint,
  MessageCreateRequest request,
  List<String> betas,
) => switch (endpoint) {
  _Endpoint.create => client.messages.create(request, betas: betas),
  _Endpoint.withResponse => client.messages.createWithResponse(
    request,
    betas: betas,
  ),
  _Endpoint.count => client.messages.countTokens(
    TokenCountRequest.fromMessageCreateRequest(request),
    betas: betas,
  ),
  _Endpoint.stream =>
    client.messages.createStream(request, betas: betas).toList(),
  _Endpoint.batch => client.messages.batches.create(
    MessageBatchCreateRequest(
      requests: [BatchRequestItem(customId: 'fixture', params: request)],
    ),
    betas: betas,
  ),
};

void _queueResponse(MockHttpClient transport, _Endpoint endpoint) {
  switch (endpoint) {
    case _Endpoint.create:
    case _Endpoint.withResponse:
      transport.queueJsonResponse(MockResponses.message());
    case _Endpoint.count:
      transport.queueJsonResponse({'input_tokens': 4});
    case _Endpoint.stream:
      transport.queueStreamingResponse(MockResponses.streamingEvents());
    case _Endpoint.batch:
      transport.queueJsonResponse(MockResponses.messageBatch());
  }
}

List<Object?> _toolResultContent(http.Request request, _Endpoint endpoint) {
  final body = jsonDecode(request.body) as Map<String, dynamic>;
  final params = endpoint == _Endpoint.batch
      ? ((body['requests'] as List<Object?>).single!
                as Map<String, dynamic>)['params']
            as Map<String, dynamic>
      : body;
  final messages = (params['messages'] as List<Object?>)
      .cast<Map<String, dynamic>>();
  final blocks = (messages.last['content'] as List<Object?>)
      .cast<Map<String, dynamic>>();
  return blocks.single['content'] as List<Object?>;
}
