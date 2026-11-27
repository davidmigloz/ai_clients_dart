import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _request = FimCompletionRequest(
  model: 'codestral-latest',
  prompt: 'return ',
  suffix: ';',
  minTokens: 1,
  promptCacheKey: 'codestral-fixture',
);

const Map<String, Object> _logprobs = {
  'content': [
    {
      'token': 'value',
      'logprob': -0.25,
      'bytes': [118, 97],
      'token_id': 42,
    },
  ],
};

void main() {
  test('FIM reads an assistant message and keeps the text getter', () async {
    const message = {'role': 'assistant', 'prefix': false, 'content': 'value'};
    const choice = {
      'index': 0,
      'message': message,
      'finish_reason': 'stop',
      'prompt_logprobs': _logprobs,
    };
    final payload = {
      'id': 'fim-1',
      'object': 'chat.completion',
      'created': 1759496862,
      'model': 'codestral-latest',
      'choices': [choice],
      'usage': {'prompt_tokens': 8, 'completion_tokens': 1, 'total_tokens': 9},
    };
    final client = MistralClient(
      config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/fim/completions');
        expect(jsonDecode(request.body), {
          'model': 'codestral-latest',
          'prompt': 'return ',
          'suffix': ';',
          'min_tokens': 1,
          'prompt_cache_key': 'codestral-fixture',
          'stream': false,
        });
        return http.Response(jsonEncode(payload), 200);
      }),
    );
    addTearDown(client.close);

    final response = await client.fim.create(request: _request);
    expect(response.choices.single.message, 'value');
    expect(response.choices.single.assistantMessage!.prefix, isFalse);
    expect(response.choices.single.promptLogprobs!.content.single.tokenId, 42);
    expect(response.choices.single.toJson(), choice);
    expect(response.usage!.totalTokens, 9);
  });

  test('FIM streams structured deltas and usage-only chunks', () async {
    const delta = {
      'content': [
        {'type': 'text', 'text': 'value'},
        {'type': 'text', 'text': ' + 1'},
      ],
      'role': 'assistant',
    };
    const choice = {
      'index': 0,
      'delta': delta,
      'finish_reason': null,
      'logprobs': _logprobs,
    };
    final client = MistralClient(
      config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/fim/completions');
        expect(request.headers['accept'], 'text/event-stream');
        expect(jsonDecode(request.body), {
          'model': 'codestral-latest',
          'prompt': 'return ',
          'suffix': ';',
          'min_tokens': 1,
          'prompt_cache_key': 'codestral-fixture',
          'stream': true,
        });
        final events = [
          {
            'id': 'fim-2',
            'model': 'codestral-latest',
            'choices': [choice],
          },
          {
            'id': 'fim-2',
            'model': 'codestral-latest',
            'choices': <Object>[],
            'usage': {
              'prompt_tokens': 8,
              'completion_tokens': 3,
              'total_tokens': 11,
            },
          },
        ];
        return http.Response(
          '${events.map((event) => 'data: ${jsonEncode(event)}\n\n').join()}'
          'data: [DONE]\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );
    addTearDown(client.close);

    final chunks = await client.fim.createStream(request: _request).toList();
    expect(chunks, hasLength(2));
    expect(chunks.first.choices.single.delta, 'value + 1');
    expect(chunks.first.choices.single.messageDelta!.role, 'assistant');
    expect(chunks.first.choices.single.logprobs!.content.single.logprob, -0.25);
    expect(chunks.first.choices.single.toJson(), choice);
    expect(chunks.last.choices, isEmpty);
    expect(chunks.last.usage!.totalTokens, 11);
  });
}
