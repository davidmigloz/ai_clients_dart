import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final streaming in [false, true]) {
    test(
      'complete response replays only an audio ID stream=$streaming (CHAT-003)',
      () async {
        var sends = 0;
        final transport = MockClient((request) async {
          sends++;
          expect(request.method, 'POST');
          expect(request.url.path, '/v1/chat/completions');
          expect(request.url.queryParameters, isEmpty);
          expect(request.headers['authorization'], 'Bearer sk-fixture');
          expect(request.headers['content-type'], 'application/json');
          if (sends == 1) {
            expect(jsonDecode(request.body), {
              'model': 'fixture-model',
              'messages': [
                {'role': 'user', 'content': 'Speak'},
              ],
            });
            return http.Response(jsonEncode(_audioCompletion()), 200);
          }
          final expected = {
            'model': 'fixture-model',
            'messages': [
              {
                'role': 'assistant',
                'reasoning_content': 'provider reasoning',
                'reasoning': 'provider summary',
                'reasoning_details': [
                  {'type': 'reasoning.text', 'text': 'provider detail'},
                ],
                'audio': {'id': 'audio_fixture'},
              },
              {'role': 'user', 'content': 'Continue'},
            ],
            if (streaming) 'stream': true,
          };
          expect(request.bodyBytes, utf8.encode(jsonEncode(expected)));
          expect(jsonDecode(request.body), expected);
          expect(request.body, isNot(contains('data-private')));
          expect(request.body, isNot(contains('transcript-private')));
          expect(request.body, isNot(contains('expires_at')));
          if (streaming) {
            expect(request.headers['accept'], 'text/event-stream');
            final chunk = {
              'id': 'chatcmpl_replay',
              'object': 'chat.completion.chunk',
              'created': 0,
              'model': 'fixture-model',
              'choices': [
                {
                  'index': 0,
                  'delta': {'content': 'ok'},
                  'finish_reason': 'stop',
                  'logprobs': null,
                },
              ],
            };
            return http.Response(
              'data: ${jsonEncode(chunk)}\n\ndata: [DONE]\n\n',
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }
          return http.Response(
            jsonEncode({
              'id': 'chatcmpl_replay',
              'object': 'chat.completion',
              'created': 0,
              'model': 'fixture-model',
              'choices': [
                {
                  'index': 0,
                  'message': {'role': 'assistant', 'content': 'ok'},
                  'finish_reason': 'stop',
                  'logprobs': null,
                },
              ],
            }),
            200,
          );
        });
        final client = _client(transport);
        addTearDown(() {
          client.close();
          transport.close();
        });
        final original = await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'fixture-model',
            messages: [ChatMessage.user('Speak')],
          ),
        );
        expect(original.text, isNull);
        expect(original.audio!.data, 'data-private');
        expect(original.audio!.transcript, 'transcript-private');
        expect(original.audio!.expiresAt, 0);
        final previous = original.firstChoice!.message;
        expect(previous.toJson()['audio'], _audioJson());
        expect(previous.toResponseJson()['content'], isNull);
        expect(previous.toResponseJson().containsKey('content'), isTrue);
        expect(previous.toApiJson(), {
          'role': 'assistant',
          'audio': {'id': 'audio_fixture'},
        });
        final replay = ChatCompletionCreateRequest(
          model: 'fixture-model',
          messages: [previous, ChatMessage.user('Continue')],
        );
        if (streaming) {
          final events = await client.chat.completions
              .createStream(replay)
              .toList();
          expect(events.single.textDelta, 'ok');
        } else {
          expect((await client.chat.completions.create(replay)).text, 'ok');
        }
        expect(previous.audio!.toJson(), _audioJson());
        expect(original.audio!.toJson(), _audioJson());
        expect(sends, 2);
      },
    );
  }

  test('an id-only reference remains an id-only public request', () async {
    final transport = MockClient((request) async {
      expect(jsonDecode(request.body), {
        'model': 'fixture-model',
        'messages': [
          {
            'role': 'assistant',
            'audio': {'id': 'audio_fixture'},
          },
        ],
      });
      return http.Response(jsonEncode(_audioCompletion()), 200);
    });
    final client = _client(transport);
    addTearDown(() {
      client.close();
      transport.close();
    });
    const request = ChatCompletionCreateRequest(
      model: 'fixture-model',
      messages: [
        AssistantMessage(audio: ChatAudio.reference(id: 'audio_fixture')),
      ],
    );
    final response = await client.chat.completions.create(request);
    expect(response.audio!.id, 'audio_fixture');
  });

  for (final incomplete in <Map<String, dynamic>>[
    {'id': 'audio_fixture'},
    {'id': 'audio_fixture', 'data': 'data-private'},
    {'id': 'audio_fixture', 'data': null, 'transcript': '', 'expires_at': 0},
  ]) {
    test('public completion rejects incomplete audio $incomplete', () async {
      final transport = MockClient((request) async {
        final json = _audioCompletion();
        ((json['choices'] as List).single as Map<String, dynamic>)['message'] =
            {'role': 'assistant', 'content': null, 'audio': incomplete};
        return http.Response(jsonEncode(json), 200);
      });
      final client = _client(transport);
      addTearDown(() {
        client.close();
        transport.close();
      });
      await expectLater(
        client.chat.completions.create(
          const ChatCompletionCreateRequest(
            model: 'fixture-model',
            messages: [],
          ),
        ),
        throwsA(
          isA<ParseException>().having(
            (error) => error.cause,
            'cause',
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains('AssistantMessage.audio'),
            ),
          ),
        ),
      );
    });
  }
}

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('sk-fixture'),
    baseUrl: 'https://api.example.invalid/v1',
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

Map<String, dynamic> _audioJson() => {
  'id': 'audio_fixture',
  'data': 'data-private',
  'transcript': 'transcript-private',
  'expires_at': 0,
};

Map<String, dynamic> _audioCompletion() => {
  'id': 'chatcmpl_fixture',
  'object': 'chat.completion',
  'created': 0,
  'model': 'fixture-model',
  'choices': [
    {
      'index': 0,
      'finish_reason': 'stop',
      'logprobs': null,
      'message': {
        'role': 'assistant',
        'content': null,
        'audio': _audioJson(),
        'reasoning_content': 'provider reasoning',
        'reasoning': 'provider summary',
        'reasoning_details': [
          {'type': 'reasoning.text', 'text': 'provider detail'},
        ],
      },
    },
  ],
};
