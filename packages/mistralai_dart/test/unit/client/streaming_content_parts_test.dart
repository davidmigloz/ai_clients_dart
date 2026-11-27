import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('streams thinking, transition and answer phases', () async {
    const model = 'mistral-large-latest';
    String event(Object content) =>
        'data: ${jsonEncode({
          'id': 'x',
          'model': model,
          'object': 'chat.completion.chunk',
          'choices': [
            {
              'index': 0,
              'delta': {'content': content},
              'finish_reason': null,
            },
          ],
        })}\n\n';

    final events = [
      event([
        {
          'type': 'thinking',
          'thinking': [
            {'type': 'text', 'text': 'Let me think'},
          ],
          'closed': false,
        },
      ]),
      event([
        {'type': 'thinking', 'thinking': <Object>[], 'closed': true},
        {'type': 'text', 'text': 'Hel'},
      ]),
      event('lo'),
      'data: [DONE]\n\n',
    ];

    final client = MistralClient(
      config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
      httpClient: MockClient.streaming(
        (request, _) async => http.StreamedResponse(
          Stream.fromIterable(events.map(utf8.encode)),
          200,
        ),
      ),
    );
    addTearDown(client.close);

    final stream = client.chat.createStream(
      request: ChatCompletionRequest(
        model: model,
        messages: [ChatMessage.user('Hi')],
      ),
    );

    expect(await stream.text, 'Hello');
  });
}
