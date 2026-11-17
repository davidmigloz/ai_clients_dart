import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test('create shallow-merges extraBody for a single request', () async {
    final bodies = <Object?>[];
    final completions = _client(
      MockClient((request) async {
        expect(request.url.path, '/v1/chat/completions');
        bodies.add(jsonDecode(request.body));
        return http.Response(jsonEncode(_completion), 200);
      }),
    ).chat.completions;
    final request = _ProviderRequest();
    final extraBody = Map<String, Object?>.unmodifiable({
      'enable_thinking': false,
      'provider_null': null,
      'metadata': {'shared': 'extra'},
      'provider_options': {
        'stop': ['END'],
      },
    });

    final completion = await completions.create(request, extraBody: extraBody);
    await completions.create(request);

    expect(completion.text, 'ok');
    expect(bodies, [
      {
        ..._requestBody,
        'enable_thinking': false,
        'provider_null': null,
        'metadata': {'shared': 'extra'},
        'provider_options': {
          'stop': ['END'],
        },
      },
      _requestBody,
    ]);
  });

  for (final accumulate in [false, true]) {
    final method = accumulate ? 'createStreamWithAccumulator' : 'createStream';
    test('$method sends extraBody and keeps the SSE response mode', () async {
      var sends = 0;
      final completions = _client(
        MockClient((request) async {
          sends++;
          expect(request.url.path, '/v1/chat/completions');
          expect(request.headers['accept'], 'text/event-stream');
          expect(jsonDecode(request.body), {
            ..._requestBody,
            'enable_thinking': false,
            'stream': true,
          });
          return http.Response(
            'data: ${jsonEncode(_chunk('o'))}\n\n'
            'data: ${jsonEncode(_chunk('k'))}\n\n'
            'data: [DONE]\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }),
      ).chat.completions;
      final request = _ProviderRequest();
      const extraBody = {'enable_thinking': false};

      if (accumulate) {
        final snapshots = await completions
            .createStreamWithAccumulator(request, extraBody: extraBody)
            .map((accumulator) => accumulator.content)
            .toList();
        expect(snapshots, ['o', 'ok']);
      } else {
        final deltas = await completions
            .createStream(request, extraBody: extraBody)
            .map((event) => event.textDelta)
            .toList();
        expect(deltas, ['o', 'k']);
      }
      expect(sends, 1);
    });
  }

  for (final value in [true, false, null]) {
    test('all methods reject extraBody stream=$value before sending', () async {
      final completions = _client(
        MockClient((_) async => fail('Invalid stream override was sent')),
      ).chat.completions;
      final request = _ProviderRequest();
      final extraBody = {'stream': value};

      await expectLater(
        completions.create(request, extraBody: extraBody),
        throwsArgumentError,
      );
      await expectLater(() async {
        await completions
            .createStream(request, extraBody: extraBody)
            .drain<void>();
      }, throwsArgumentError);
      await expectLater(() async {
        await completions
            .createStreamWithAccumulator(request, extraBody: extraBody)
            .drain<void>();
      }, throwsArgumentError);
    });
  }
}

OpenAIClient _client(MockClient transport) {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('fixture-key'),
      baseUrl: 'https://api.example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  addTearDown(() {
    client.close();
    transport.close();
  });
  return client;
}

const Map<String, Object?> _requestBody = {
  'model': 'fixture-model',
  'messages': [
    {'role': 'user', 'content': 'Hello'},
  ],
  'metadata': {'shared': 'typed', 'typed_only': 'value'},
  'legacy_provider_field': 'preserved',
};

class _ProviderRequest extends ChatCompletionCreateRequest {
  _ProviderRequest()
    : super(
        model: 'fixture-model',
        messages: [ChatMessage.user('Hello')],
        metadata: const {'shared': 'typed', 'typed_only': 'value'},
      );

  @override
  Map<String, dynamic> toJson() => Map.unmodifiable({
    ...super.toJson(),
    'legacy_provider_field': 'preserved',
  });
}

const Map<String, Object?> _completion = {
  'id': 'chatcmpl_fixture',
  'object': 'chat.completion',
  'created': 0,
  'model': 'fixture-model',
  'choices': [
    {
      'index': 0,
      'finish_reason': 'stop',
      'message': {'role': 'assistant', 'content': 'ok'},
    },
  ],
};

Map<String, Object?> _chunk(String text) => {
  'id': 'chatcmpl_fixture',
  'object': 'chat.completion.chunk',
  'created': 0,
  'model': 'fixture-model',
  'choices': [
    {
      'index': 0,
      'delta': {'content': text},
    },
  ],
};
