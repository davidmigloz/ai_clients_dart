import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _legacy = {'type': 'text', 'text': 'Earlier response'};
const Map<String, String?> _canonical = {
  'type': 'text',
  'text': 'No citations',
  'citations': null,
};
const Map<String, Object> _empty = {
  'type': 'text',
  'text': 'Empty citations',
  'citations': [],
};
const Map<String, Object> _cited = {
  'type': 'text',
  'text': 'Cited response',
  'citations': [
    {
      'type': 'char_location',
      'cited_text': 'A',
      'document_index': 0,
      'document_title': null,
      'file_id': null,
      'start_char_index': 0,
      'end_char_index': 1,
    },
  ],
};

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;
  final request = MessageCreateRequest(
    model: 'fixture-model',
    maxTokens: 16,
    messages: [InputMessage.user('What does the document say?')],
  );

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
  });

  test(
    'Messages keeps citation presence without adding null to replay',
    () async {
      const content = [_legacy, _canonical, _empty, _cited];
      transport
        ..queueJsonResponse({...MockResponses.message(), 'content': content})
        ..queueJsonResponse(MockResponses.message());

      final message = await client.messages.create(request);
      expect(message.toJson()['content'], content);
      final blocks = message.content.cast<TextBlock>();
      expect(blocks[0].copyWith().toJson(), _legacy);
      expect(blocks[1].copyWith().toJson(), _canonical);
      expect(blocks[2].copyWith().toJson(), _empty);
      expect(blocks[3].copyWith().toJson(), _cited);
      expect(
        blocks[3].copyWith(citations: null).toJson(),
        containsPair('citations', null),
      );

      await client.messages.create(
        request.copyWith(
          messages: [...request.messages, message.toInputMessage()],
        ),
      );
      final body =
          jsonDecode((transport.lastRequest! as http.Request).body)
              as Map<String, dynamic>;
      final messages = body['messages'] as List<dynamic>;
      final assistant = messages.last as Map<String, dynamic>;
      final replay = assistant['content'] as List<dynamic>;
      expect(assistant['role'], 'assistant');
      expect(replay[0], _legacy);
      expect(replay[1], {'type': 'text', 'text': 'No citations'});
      expect(replay[2], _empty);
      expect(replay[3], contains('citations'));
      expect((replay[3] as Map)['citations'], hasLength(1));
    },
  );

  test('SSE text start and final message keep canonical null', () async {
    final events = MockResponses.streamingEvents(text: 'Streamed');
    final start = events.firstWhere(
      (event) => event['type'] == 'content_block_start',
    );
    start['content_block'] = {
      ...start['content_block'] as Map<String, dynamic>,
      'citations': null,
    };
    transport.queueStreamingResponse(events);

    final message = await client.messages.createStream(request).map((event) {
      if (event is ContentBlockStartEvent) {
        expect(event.contentBlock.toJson(), containsPair('citations', null));
      }
      return event;
    }).finalMessage();
    expect(message.text, 'Streamed');
    expect(message.toJson()['content'], [
      {'type': 'text', 'text': 'Streamed', 'citations': null},
    ]);
  });

  test('batch results preserve the response text block', () async {
    final line = jsonEncode({
      'custom_id': 'job',
      'result': {
        'type': 'succeeded',
        'message': {
          ...MockResponses.message(),
          'content': [_canonical],
        },
      },
    });
    transport.queueResponse(
      MockResponse(
        body: '$line\n',
        headers: const {'content-type': 'application/x-jsonl'},
      ),
    );

    final result = await client.batches.results('msgbatch_fixture').single;
    final success = result.result as BatchResultSucceeded;
    expect(success.message.toJson()['content'], [_canonical]);
  });

  test(
    'the existing const text constructor still omits a null citation list',
    () {
      const block = TextBlock(text: 'Constructed', citations: null);
      expect(block.toJson(), {'type': 'text', 'text': 'Constructed'});
      expect(block.copyWith().toJson(), block.toJson());
    },
  );
}
