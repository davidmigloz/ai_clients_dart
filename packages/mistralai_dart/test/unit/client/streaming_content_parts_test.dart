import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('streams thinking, transition and answer phases', () async {
    String event(Object content) =>
        'data: ${jsonEncode({
          'id': 'x',
          'object': 'chat.completion.chunk',
          'choices': [
            {
              'index': 0,
              'delta': {'content': content},
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
        {'type': 'text', 'text': 'Bon'},
      ]),
      event('jour'),
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

    final stream = client.chat.createStream(
      request: ChatCompletionRequest(
        model: 'mistral-large-latest',
        messages: [ChatMessage.user('Hello')],
      ),
    );

    expect(await stream.text, 'Bonjour');
    client.close();
  });
}
