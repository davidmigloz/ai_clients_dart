import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'local SSE reconstructs interleaved audio without mixing other output (CHAT-004/005)',
    () async {
      final chunks = [
        _chunk([
          _choice(0, {
            'role': 'assistant',
            'content': 'Hello ',
            'audio': <String, dynamic>{},
          }),
          _choice(1, {'role': 'assistant'}),
        ]),
        _chunk([
          _choice(1, {
            'audio': {'id': 'audio_1'},
          }),
        ]),
        _chunk([
          _choice(0, {
            'audio': {'data': 'Y'},
          }),
        ]),
        _chunk([
          _choice(0, {
            'audio': {'transcript': 'he'},
          }),
        ]),
        _chunk([
          _choice(1, {
            'audio': {'data': 'Yg', 'transcript': 'first'},
          }),
          _choice(0, {
            'audio': {'id': 'audio_initial', 'data': 'Q=='},
            'tool_calls': [
              {
                'index': 0,
                'id': 'call_fixture',
                'type': 'function',
                'function': {'name': 'lookup', 'arguments': '{"x":'},
              },
            ],
          }),
        ]),
        _chunk([
          _choice(0, {
            'content': 'world',
            'refusal': 'No.',
            'reasoning_content': 'reasoning',
            'reasoning': 'summary',
            'reasoning_details': [
              {'type': 'reasoning.text', 'text': 'detail'},
            ],
            'tool_calls': [
              {
                'index': 0,
                'function': {'arguments': '1}'},
              },
            ],
            'audio': {'id': 'audio_0', 'transcript': 'llo'},
          }),
        ]),
        _chunk([
          _choice(1, {
            'audio': {'data': '==', 'transcript': ' second', 'expires_at': 21},
          }, finish: 'length'),
        ]),
        {
          ..._chunk([
            _choice(0, {
              'audio': {'expires_at': 0},
            }),
          ]),
          'obfuscation': 'padding-private',
        },
        {..._chunk([]), 'usage': _usageJson()},
      ];
      await _withLocalStream(chunks, (client) async {
        final accumulator = ChatStreamAccumulator();
        final events = <ChatStreamEvent>[];
        ChatAudioDelta? earlyAudio;
        ChatAudioDelta? transcriptSnapshot;
        List<AccumulatedChoice>? earlyChoices;
        await for (final event in client.chat.completions.createStream(
          _request(),
        )) {
          events.add(event);
          accumulator.add(event);
          if (events.length == 3) {
            earlyAudio = accumulator.audio;
            earlyChoices = accumulator.choices;
          }
          if (events.length == 4) transcriptSnapshot = accumulator.audio;
        }
        expect(events, hasLength(9));
        expect(events[0].firstChoice!.delta.audio!.toJson(), isEmpty);
        expect(events[1].firstChoice!.delta.audio!.toJson(), {'id': 'audio_1'});
        expect(events[2].firstChoice!.delta.audio!.toJson(), {'data': 'Y'});
        expect(events[3].firstChoice!.delta.audio!.toJson(), {
          'transcript': 'he',
        });
        expect(transcriptSnapshot!.toJson(), {'data': 'Y', 'transcript': 'he'});
        expect(events[7].firstChoice!.delta.audio!.toJson(), {'expires_at': 0});
        expect(events[7].firstChoice!.finishReason, isNull);
        expect(events[7].firstChoice!.isFinal, isFalse);
        expect(events[7].obfuscation, 'padding-private');
        expect(events.last.choices, isEmpty);
        expect(events.last.textDelta, isNull);
        expect(accumulator.audio!.toJson(), {
          'id': 'audio_0',
          'data': 'YQ==',
          'transcript': 'hello',
          'expires_at': 0,
        });
        expect(accumulator.choices[1].audio!.toJson(), {
          'id': 'audio_1',
          'data': 'Yg==',
          'transcript': 'first second',
          'expires_at': 21,
        });
        expect(earlyAudio!.toJson(), {'data': 'Y'});
        expect(earlyChoices![0].audio, earlyAudio);
        expect(earlyChoices[0].content, 'Hello ');
        expect(earlyChoices[1].audio!.toJson(), {'id': 'audio_1'});
        expect(accumulator.content, 'Hello world');
        expect(accumulator.refusal, 'No.');
        expect(accumulator.reasoningContent, 'reasoning');
        expect(accumulator.reasoning, 'summary');
        expect(accumulator.choices[0].reasoningDetails.single.text, 'detail');
        expect(accumulator.toolCalls.single.function.arguments, '{"x":1}');
        expect(accumulator.finishReason, isNull);
        expect(accumulator.choices[0].finishReason, isNull);
        expect(accumulator.choices[1].finishReason, FinishReason.length);
        expect(accumulator.usage!.toJson(), _usageJson());
        final completion = accumulator.toChatCompletion();
        expect(completion.audio!.toJson(), accumulator.audio!.toJson());
        expect(completion.choices[0].finishReason, FinishReason.stop);
        expect(completion.choices[1].finishReason, FinishReason.length);
        expect(
          completion.choices[1].message.audio!.toJson(),
          accumulator.choices[1].audio!.toJson(),
        );
        expect(completion.usage, accumulator.usage);
        expect(completion.text, 'Hello world');
        expect(
          jsonEncode(completion.toJson()),
          isNot(contains('padding-private')),
        );
        accumulator.reset();
        expect(accumulator.audio, isNull);
        expect(accumulator.choices, isEmpty);
        expect(accumulator.usage, isNull);
        expect(earlyAudio.toJson(), {'data': 'Y'});
      });
    },
  );

  for (final finish in <String?>[null, 'length']) {
    test('local expiry-only update preserves earlier finish=$finish', () async {
      await _withLocalStream(
        [
          _chunk([
            _choice(0, {
              'role': 'assistant',
              'audio': {'id': 'audio_fixture', 'data': '', 'transcript': ''},
            }),
          ]),
          if (finish != null) _chunk([_choice(0, null, finish: finish)]),
          _chunk([
            _choice(0, {
              'audio': {'expires_at': 0},
            }),
          ]),
        ],
        (client) async {
          final events = await client.chat.completions
              .createStream(_request())
              .toList();
          final accumulator = ChatStreamAccumulator();
          events.forEach(accumulator.add);
          expect(events.last.firstChoice!.finishReason, isNull);
          expect(accumulator.audio!.isComplete, isTrue);
          expect(
            accumulator.finishReason,
            finish == null ? null : FinishReason.length,
          );
          expect(
            accumulator.toChatCompletion().choices[0].finishReason,
            finish == null ? FinishReason.stop : FinishReason.length,
          );
        },
      );
    });
  }

  for (final audio in <Map<String, dynamic>>[
    {},
    {'id': 'audio_fixture'},
  ]) {
    test(
      'public partial audio remains inspectable but cannot fabricate completion: ${audio.keys}',
      () async {
        await _withLocalStream(
          [
            _chunk([
              _choice(0, {'audio': audio}),
            ]),
          ],
          (client) async {
            final events = await client.chat.completions
                .createStream(_request())
                .toList();
            final accumulator = ChatStreamAccumulator()..add(events.single);
            expect(accumulator.audio!.toJson(), audio);
            expect(accumulator.audio!.isComplete, isFalse);
            expect(accumulator.toChatCompletion, throwsStateError);
          },
        );
      },
    );
  }

  for (final invalid in <Object?>[
    null,
    false,
    <Object>[],
    'audio',
    {'id': null},
    {'data': null},
    {'transcript': null},
    {'expires_at': null},
    {'expires_at': 1.5},
    {'id': 7},
    {'data': <Object>[]},
    {'transcript': false},
  ]) {
    test('public stream rejects malformed supplied audio: $invalid', () async {
      await _withLocalStream(
        [
          _chunk([
            _choice(0, {'audio': invalid}),
          ]),
        ],
        (client) async {
          await expectLater(
            client.chat.completions.createStream(_request()).toList(),
            throwsA(
              isA<ParseException>().having(
                (e) => e.cause,
                'cause',
                isA<FormatException>().having(
                  (e) => e.message,
                  'context',
                  contains('ChatDelta.audio'),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

Future<void> _withLocalStream(
  List<Map<String, dynamic>> chunks,
  Future<void> Function(OpenAIClient client) consume,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  var sends = 0;
  String? method;
  String? path;
  String? authorization;
  String? accept;
  String? contentType;
  Map<String, dynamic>? body;
  final subscription = server.listen((request) async {
    sends++;
    method = request.method;
    path = request.uri.path;
    authorization = request.headers.value('authorization');
    accept = request.headers.value('accept');
    contentType = request.headers.value('content-type');
    body =
        jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>;
    request.response.headers.contentType = ContentType('text', 'event-stream');
    for (final chunk in chunks) {
      request.response.write('data: ${jsonEncode(chunk)}\n\n');
      await request.response.flush();
    }
    request.response.write('data: [DONE]\n\n');
    await request.response.close();
  });
  final client = OpenAIClient(
    config: OpenAIConfig(
      authProvider: const ApiKeyProvider('sk-fixture'),
      baseUrl: 'http://127.0.0.1:${server.port}/v1',
      retryPolicy: const RetryPolicy(maxRetries: 0),
      timeout: const Duration(seconds: 5),
    ),
  );
  try {
    await consume(client);
    expect(sends, 1);
    expect(method, 'POST');
    expect(path, '/v1/chat/completions');
    expect(authorization, 'Bearer sk-fixture');
    expect(accept, 'text/event-stream');
    expect(contentType, 'application/json');
    expect(body, {
      'model': 'fixture-audio-model',
      'messages': [
        {'role': 'user', 'content': 'Hello'},
      ],
      'n': 2,
      'modalities': ['text', 'audio'],
      'audio': {'voice': 'alloy', 'format': 'pcm16'},
      'stream_options': {'include_usage': true, 'include_obfuscation': true},
      'stream': true,
    });
  } finally {
    client.close();
    await server.close(force: true);
    await subscription.cancel();
  }
}

ChatCompletionCreateRequest _request() => ChatCompletionCreateRequest(
  model: 'fixture-audio-model',
  messages: [ChatMessage.user('Hello')],
  n: 2,
  modalities: const [ChatModality.text, ChatModality.audio],
  audio: const ChatAudioConfig(
    voice: ChatAudioVoice.alloy,
    format: ChatAudioFormat.pcm16,
  ),
  streamOptions: const StreamOptions(
    includeUsage: true,
    includeObfuscation: true,
  ),
);

Map<String, dynamic> _choice(
  int index,
  Map<String, dynamic>? delta, {
  String? finish,
}) => {
  'index': index,
  'delta': delta,
  'finish_reason': finish,
  'logprobs': null,
};

Map<String, dynamic> _chunk(List<Map<String, dynamic>> choices) => {
  'id': 'chatcmpl_fixture',
  'object': 'chat.completion.chunk',
  'created': 0,
  'model': 'fixture-audio-model',
  'choices': choices,
};

Map<String, dynamic> _usageJson() => {
  'prompt_tokens': 5,
  'completion_tokens': 3,
  'total_tokens': 8,
  'prompt_tokens_details': {
    'audio_tokens': 0,
    'cached_tokens': 0,
    'cache_write_tokens': 0,
    'text_tokens': 5,
    'image_tokens': 0,
  },
  'completion_tokens_details': {
    'audio_tokens': 3,
    'text_tokens': 0,
    'reasoning_tokens': 0,
    'accepted_prediction_tokens': 0,
    'rejected_prediction_tokens': 0,
  },
};
