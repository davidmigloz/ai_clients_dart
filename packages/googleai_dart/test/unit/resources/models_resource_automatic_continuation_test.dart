import 'dart:async' show Completer, StreamController;
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const _model = 'gemini-4-hydrogen';
const _request = GenerateContentRequest(
  contents: [
    Content.user([TextPart('Write a report.')]),
  ],
  generationConfig: GenerationConfig(maxOutputTokens: 120000),
);

GoogleAIClient _client(
  http.Client transport, {
  GoogleAIConfig config = const GoogleAIConfig(),
}) {
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

Map<String, Object> _candidate({
  String? text,
  String? finish,
  String? token,
  int? index,
}) => {
  if (text != null)
    'content': {
      'role': 'model',
      'parts': [
        {'text': text},
      ],
    },
  'finishReason': ?finish,
  'continuationToken': ?token,
  'index': ?index,
};

Map<String, Object> _chunk({
  String? text,
  String? finish,
  String? token,
  Map<String, Object>? usage,
}) => {
  'candidates': [_candidate(text: text, finish: finish, token: token)],
  'usageMetadata': ?usage,
};

http.Response _jsonResponse(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: const {'content-type': 'application/json'},
);

Stream<List<int>> _stream(
  List<Map<String, Object>> frames, {
  bool drops = false,
}) async* {
  for (final frame in frames) {
    yield utf8.encode('data: ${jsonEncode(frame)}\n\n');
  }
  if (drops) throw http.ClientException('fixture connection dropped');
}

http.StreamedResponse _sse(
  List<Map<String, Object>> frames, {
  bool drops = false,
}) => http.StreamedResponse(
  _stream(frames, drops: drops),
  200,
  headers: const {'content-type': 'text/event-stream'},
);

Future<Map<String, dynamic>> _body(Stream<List<int>> bytes) async =>
    jsonDecode(await utf8.decodeStream(bytes)) as Map<String, dynamic>;

void main() {
  for (final stream in [false, true]) {
    test(
      'protects retained checkpoints in ${stream ? 'SSE' : 'unary'} errors',
      () async {
        const earlier = 'fixture+earlier/private';
        const current = 'fixture+current/private';
        const encoded = 'fixture%2bcurrent%2fprivate';
        const voice = 'voicekey_fixture_prediction';
        final previousLevel = Logger.root.level;
        Logger.root.level = Level.FINE;
        addTearDown(() => Logger.root.level = previousLevel);
        final logs = <LogRecord>[];
        final subscription = Logger.root.onRecord.listen(logs.add);
        addTearDown(subscription.cancel);

        final speakers = [
          const SpeakerVoiceConfig(voiceConfig: VoiceConfig(voice: voice)),
        ];
        final request = _request.copyWith(
          generationConfig: GenerationConfig(
            speechConfig: SpeechConfig(
              multiSpeakerVoiceConfig: MultiSpeakerVoiceConfig(
                speakerVoiceConfigs: speakers,
              ),
            ),
          ),
        );
        final tokens = <Object?>[];
        final client = _client(
          MockClient((wire) async {
            final body = jsonDecode(wire.body) as Map<String, dynamic>;
            tokens.add(body['continuationToken']);
            expect(wire.body, contains(voice));
            speakers.clear();
            final response = switch (tokens.length) {
              1 => _chunk(finish: 'CONTINUATION', token: earlier),
              2 => _chunk(finish: 'CONTINUATION', token: current),
              _ => {
                'error': {
                  'message': 'Rejected $earlier $current $encoded $voice',
                  'details': [
                    {'echo': '$earlier $current $encoded $voice'},
                  ],
                },
              },
            };
            if (stream) {
              return http.Response(
                'data: ${jsonEncode(response)}\n\n',
                200,
                headers: const {'content-type': 'text/event-stream'},
              );
            }
            return http.Response(
              jsonEncode(response),
              tokens.length < 3 ? 200 : 400,
              headers: {
                'content-type': 'application/json',
                if (tokens.length == 3)
                  'x-provider-echo': '$earlier $current $encoded $voice',
              },
            );
          }),
        );
        final safe = allOf(
          contains('***REDACTED***'),
          isNot(contains(earlier)),
          isNot(contains(current)),
          isNot(contains(encoded)),
          isNot(contains(voice)),
        );
        if (stream) {
          await expectLater(
            client.models.streamGenerateContent(
              model: _model,
              request: request,
              automaticContinuation: true,
            ),
            emitsInOrder([
              isA<GenerateContentResponse>(),
              isA<GenerateContentResponse>(),
              emitsError(
                isA<StreamException>()
                    .having((e) => e.message, 'message', safe)
                    .having((e) => e.partialData, 'partial SSE data', safe),
              ),
              emitsDone,
            ]),
          );
        } else {
          await expectLater(
            client.models.generateContent(
              model: _model,
              request: request,
              automaticContinuation: true,
            ),
            throwsA(
              isA<ApiException>()
                  .having((e) => e.message, 'message', safe)
                  .having((e) => e.details.toString(), 'details', safe)
                  .having(
                    (e) => e.responseMetadata?.headers['x-provider-echo'],
                    'echoed response header',
                    safe,
                  ),
            ),
          );
        }
        expect(tokens, [null, earlier, current]);
        final errors = logs.where((r) => r.level >= Level.WARNING);
        expect(errors, isNotEmpty);
        expect(errors.map((r) => '${r.message} ${r.error}').join(' '), safe);
        expect(logs.map((r) => '${r.message} ${r.error}').join(' '), safe);
      },
    );
  }

  test(
    'protects checkpoint echoes later in the same accepted stream',
    () async {
      const checkpoint = 'fixture+new/private';
      final client = _client(
        MockClient.streaming((request, bytes) async {
          expect((await _body(bytes))['continuationToken'], isNull);
          return _sse([
            _chunk(text: 'First', token: checkpoint),
            {
              'error': {'message': 'Provider reflected $checkpoint'},
            },
          ]);
        }),
      );
      await expectLater(
        client.models.streamGenerateContent(
          model: _model,
          request: _request,
          automaticContinuation: true,
        ),
        emitsInOrder([
          isA<GenerateContentResponse>(),
          emitsError(
            isA<StreamException>().having(
              (e) => e.message,
              'message',
              'Provider reflected ***REDACTED***',
            ),
          ),
          emitsDone,
        ]),
      );
    },
  );

  test(
    'unary continuation preserves inputs and merges candidate usage',
    () async {
      final requests = <Map<String, dynamic>>[];
      final labels = {'purpose': 'initial'};
      final request = _request.copyWith(labels: labels);
      final original =
          jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>;
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.host, 'aiplatform.eu.rep.googleapis.com');
          expect(
            request.url.path,
            '/v1beta1/projects/sample/locations/eu/publishers/google/models/$_model:generateContent',
          );
          expect(request.headers['authorization'], 'Bearer fixture');
          requests.add(jsonDecode(request.body) as Map<String, dynamic>);
          labels['purpose'] = 'changed after first send';
          if (requests.length == 1) {
            return _jsonResponse({
              'candidates': [
                _candidate(
                  text: 'Hello ',
                  finish: 'CONTINUATION',
                  token: 'checkpoint',
                  index: 0,
                ),
                _candidate(text: 'Alternate ', index: 1),
                _candidate(text: 'Already done.', finish: 'STOP', index: 2),
              ],
              'usageMetadata': {
                'promptTokenCount': 4,
                'candidatesTokenCount': 2,
                'cachedContentTokenCount': 1,
                'totalTokenCount': 6,
                'promptTokensDetails': [
                  {'modality': 'TEXT', 'tokenCount': 4},
                ],
              },
              'responseId': 'first',
            });
          }
          return _jsonResponse({
            'candidates': [
              _candidate(text: 'answer.', finish: 'STOP', index: 1),
              _candidate(text: 'world.', finish: 'STOP', index: 0),
            ],
            'usageMetadata': {
              'promptTokenCount': 7,
              'candidatesTokenCount': 3,
              'thoughtsTokenCount': 2,
              'totalTokenCount': 12,
              'promptTokensDetails': [
                {'modality': 'TEXT', 'tokenCount': 5},
                {'modality': 'IMAGE', 'tokenCount': 2},
              ],
            },
            'responseId': 'last',
          });
        }),
        config: GoogleAIConfig.vertexAI(
          projectId: 'sample',
          location: 'eu',
          apiVersion: ApiVersion.v1beta1,
          authProvider: const BearerTokenProvider('fixture'),
        ),
      );
      final result = await client.models.generateContent(
        model: _model,
        request: request,
        automaticContinuation: true,
      );
      expect(requests, [
        original,
        {...original, 'continuationToken': 'checkpoint'},
      ]);
      expect(result.candidates?.first.text, 'Hello world.');
      expect(result.candidates?[1].text, 'Alternate answer.');
      expect(result.candidates?.last.text, 'Already done.');
      expect(result.candidates?.last.finishReason, FinishReason.stop);
      expect(result.candidates?.first.continuationToken, isNull);
      expect(result.candidates?.first.finishReason, FinishReason.stop);
      expect(result.responseId, 'last');
      final usage = result.usageMetadata!;
      expect(usage.initialPromptTokenCount, 4);
      expect(usage.copyWith().initialPromptTokenCount, 4);
      expect(usage.toJson(), {
        'promptTokenCount': 11,
        'candidatesTokenCount': 5,
        'cachedContentTokenCount': 1,
        'thoughtsTokenCount': 2,
        'totalTokenCount': 18,
        'promptTokensDetails': [
          {'modality': 'TEXT', 'tokenCount': 9},
          {'modality': 'IMAGE', 'tokenCount': 2},
        ],
      });
    },
  );

  test(
    'default and terminal unary responses leave the token to the caller',
    () async {
      for (final (automatic, finish, token, initial) in [
        (false, 'CONTINUATION', 'fresh', null),
        (true, 'MAX_TOKENS', 'fresh', null),
        (true, 'CONTINUATION', null, null),
        (true, 'CONTINUATION', 'same', 'same'),
      ]) {
        var calls = 0;
        final client = _client(
          MockClient((request) async {
            calls++;
            expect(request.url.path, '/v1beta/models/$_model:generateContent');
            expect(jsonDecode(request.body), {
              ..._request.toJson(),
              'continuationToken': ?initial,
            });
            return _jsonResponse(
              _chunk(text: 'Partial', finish: finish, token: token),
            );
          }),
        );
        final result = await client.models.generateContent(
          model: _model,
          request: _request.copyWith(continuationToken: initial),
          automaticContinuation: automatic,
        );
        expect(result.text, 'Partial');
        expect(result.candidates?.single.continuationToken, token);
        expect(result.candidates?.single.toJson()['finishReason'], finish);
        expect(calls, 1);
      }
    },
  );

  test(
    'stream usage replaces running totals per hop and sums across hops',
    () async {
      final requests = <Map<String, dynamic>>[];
      final client = _client(
        MockClient.streaming((request, bytes) async {
          expect(
            request.url.path,
            '/v1beta/models/$_model:streamGenerateContent',
          );
          expect(request.url.queryParameters, {'alt': 'sse'});
          requests.add(await _body(bytes));
          return requests.length == 1
              ? _sse([
                  _chunk(
                    text: 'Hello ',
                    usage: {'promptTokenCount': 3, 'totalTokenCount': 4},
                  ),
                  _chunk(finish: 'CONTINUATION', token: 'checkpoint'),
                  {
                    'usageMetadata': {
                      'promptTokenCount': 3,
                      'totalTokenCount': 5,
                    },
                  },
                ])
              : _sse([
                  _chunk(
                    text: 'world',
                    finish: 'STOP',
                    usage: {'promptTokenCount': 8, 'totalTokenCount': 9},
                  ),
                ]);
        }),
      );
      final frames = await client.models
          .streamGenerateContent(
            model: _model,
            request: _request,
            automaticContinuation: true,
          )
          .toList();
      expect(requests, [
        _request.toJson(),
        {..._request.toJson(), 'continuationToken': 'checkpoint'},
      ]);
      expect(
        frames.map((frame) => frame.text).whereType<String>().join(),
        'Hello world',
      );
      expect(frames[1].candidates?.single.finishReason, isNull);
      expect(frames.last.candidates?.single.finishReason, FinishReason.stop);
      expect(frames.map((frame) => frame.usageMetadata?.totalTokenCount), [
        4,
        null,
        5,
        14,
      ]);
      expect(frames.last.usageMetadata?.initialPromptTokenCount, 3);
      expect(frames.last.usageMetadata?.promptTokenCount, 11);
    },
  );

  test('only safe drop checkpoints are replayed', () async {
    for (final extraOutput in [false, true]) {
      final requests = <Map<String, dynamic>>[];
      final client = _client(
        MockClient.streaming((request, bytes) async {
          requests.add(await _body(bytes));
          return requests.length == 1
              ? _sse([
                  _chunk(text: 'Checkpoint ', token: 'checkpoint'),
                  if (extraOutput) _chunk(text: 'uncheckpointed'),
                ], drops: true)
              : _sse([_chunk(text: 'resumed', finish: 'STOP')]);
        }),
      );
      final stream = client.models
          .streamGenerateContent(
            model: _model,
            request: _request,
            automaticContinuation: true,
          )
          .map((frame) => frame.text);
      if (extraOutput) {
        await expectLater(
          stream,
          emitsInOrder([
            'Checkpoint ',
            'uncheckpointed',
            emitsError(isA<http.ClientException>()),
            emitsDone,
          ]),
        );
        expect(requests, hasLength(1));
      } else {
        expect(await stream.toList(), ['Checkpoint ', 'resumed']);
        expect(requests.last['continuationToken'], 'checkpoint');
        expect(requests, hasLength(2));
      }
    }
  });

  test('unary hops preserve parts and shift grounding references', () async {
    var calls = 0;
    final client = _client(
      MockClient((request) async {
        final first = ++calls == 1;
        final uri = 'https://example.com/$calls';
        return _jsonResponse({
          'candidates': [
            {
              ..._candidate(
                finish: first ? 'CONTINUATION' : 'STOP',
                token: first ? 'checkpoint' : null,
              ),
              'content': {
                'role': 'model',
                'parts': [
                  if (first) {'text': 'Planning', 'thought': true},
                  {'text': 'Result $calls', 'thoughtSignature': 'AQI='},
                ],
              },
              'groundingMetadata': {
                'groundingChunks': [
                  {
                    'web': {'uri': uri},
                  },
                ],
                'groundingSupports': [
                  {
                    'segment': {'partIndex': first ? 1 : 0},
                    'groundingChunkIndices': [0],
                    'renderedParts': [if (first) 1 else 0],
                  },
                ],
              },
              'urlContextMetadata': {
                'urlMetadata': [
                  {'retrievedUrl': uri},
                ],
              },
            },
          ],
        });
      }),
    );
    final response = await client.models.generateContent(
      model: _model,
      request: _request,
      automaticContinuation: true,
    );
    final candidate = response.candidates!.single;
    expect(candidate.content?.parts.map((part) => part.toJson()), [
      {'text': 'Planning', 'thought': true},
      {'text': 'Result 1', 'thoughtSignature': 'AQI='},
      {'text': 'Result 2', 'thoughtSignature': 'AQI='},
    ]);
    final grounding = candidate.groundingMetadata!;
    expect(grounding.groundingChunks?.map((chunk) => chunk.web?.uri), [
      'https://example.com/1',
      'https://example.com/2',
    ]);
    expect(grounding.groundingSupports?.map((support) => support.toJson()), [
      {
        'segment': {'partIndex': 1},
        'groundingChunkIndices': [0],
        'renderedParts': [1],
      },
      {
        'segment': {'partIndex': 2},
        'groundingChunkIndices': [1],
        'renderedParts': [2],
      },
    ]);
    expect(candidate.urlContextMetadata?['urlMetadata'], [
      {'retrievedUrl': 'https://example.com/1'},
      {'retrievedUrl': 'https://example.com/2'},
    ]);
  });

  test('repeated and missing boundary tokens stay observable', () async {
    for (final token in [null, 'same']) {
      var calls = 0;
      final client = _client(
        MockClient.streaming((request, bytes) async {
          calls++;
          expect((await _body(bytes))['continuationToken'], 'same');
          return _sse([_chunk(finish: 'CONTINUATION', token: token)]);
        }),
      );
      final response = await client.models
          .streamGenerateContent(
            model: _model,
            request: _request.copyWith(continuationToken: 'same'),
            automaticContinuation: true,
          )
          .single;
      expect(
        response.candidates?.single.finishReason,
        FinishReason.continuation,
      );
      expect(response.candidates?.single.continuationToken, token);
      expect(calls, 1);
    }
  });

  test('pre-output reconnects from a checkpoint are bounded', () async {
    final tokens = <Object?>[];
    final client = _client(
      MockClient.streaming((request, bytes) async {
        tokens.add((await _body(bytes))['continuationToken']);
        return tokens.length == 1
            ? _sse([_chunk(finish: 'CONTINUATION', token: 'checkpoint')])
            : _sse([], drops: true);
      }),
    );
    await expectLater(
      client.models.streamGenerateContent(
        model: _model,
        request: _request,
        automaticContinuation: true,
      ),
      emitsInOrder([
        isA<GenerateContentResponse>(),
        emitsError(isA<http.ClientException>()),
        emitsDone,
      ]),
    );
    expect(tokens, [null, ...List.filled(4, 'checkpoint')]);
  });

  test('precompleted abort prevents the first unary request', () async {
    final client = _client(
      MockClient((_) async => fail('Unexpected HTTP request')),
    );
    await expectLater(
      client.models.generateContent(
        model: _model,
        request: _request,
        automaticContinuation: true,
        abortTrigger: Future<void>.value(),
      ),
      throwsA(isA<AbortedException>()),
    );
  });

  test(
    'cancellation aborts a pending stream hop and prevents another',
    () async {
      final active = Completer<void>();
      final canceled = Completer<void>();
      var calls = 0;
      final pending = StreamController<List<int>>(
        onListen: active.complete,
        onCancel: canceled.complete,
      );
      final client = _client(
        MockClient.streaming((request, bytes) async {
          calls++;
          final body = await _body(bytes);
          if (calls == 1) {
            return _sse([_chunk(finish: 'CONTINUATION', token: 'checkpoint')]);
          }
          expect(body['continuationToken'], 'checkpoint');
          return http.StreamedResponse(pending.stream, 200);
        }),
      );
      final subscription = client.models
          .streamGenerateContent(
            model: _model,
            request: _request,
            automaticContinuation: true,
          )
          .listen((_) {});
      await active.future;
      await subscription.cancel();
      await canceled.future;
      await pending.close();
      expect(calls, 2);
    },
  );

  test('unary deadline also cancels a pending continuation response', () async {
    final pending = StreamController<List<int>>();
    final canceled = Completer<void>();
    pending.onCancel = canceled.complete;
    final tokens = <Object?>[];
    final client = _client(
      MockClient.streaming((request, bytes) async {
        tokens.add((await _body(bytes))['continuationToken']);
        if (tokens.length == 1) {
          final response = jsonEncode(
            _chunk(finish: 'CONTINUATION', token: 'checkpoint'),
          );
          return http.StreamedResponse(
            Stream.value(utf8.encode(response)),
            200,
          );
        }
        return http.StreamedResponse(pending.stream, 200);
      }),
      config: const GoogleAIConfig(timeout: Duration(milliseconds: 150)),
    );
    await expectLater(
      client.models.generateContent(
        model: _model,
        request: _request,
        automaticContinuation: true,
      ),
      throwsA(isA<TimeoutException>()),
    );
    await canceled.future;
    await pending.close();
    expect(tokens, [null, 'checkpoint']);
  });
}
