import 'dart:async' show Completer, StreamController;
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _model = 'gemini-4-neon';
const _input = TextInput('Original prompt');
const _generation = InteractionGenerationConfig(maxOutputTokens: 131072);
const Map<String, Object> _userStep = {
  'type': 'user_input',
  'content': [
    {'type': 'text', 'text': 'Original prompt'},
  ],
};

Map<String, dynamic> _output(String text) => {
  'type': 'model_output',
  'content': [
    {'type': 'text', 'text': text},
  ],
};

Map<String, dynamic> _hop(
  String id, {
  String status = 'completed',
  String? token,
  List<Object> steps = const [],
  Map<String, dynamic> fields = const {},
}) => {
  'id': id,
  'status': status,
  'continuation_token': ?token,
  'steps': steps,
  ...fields,
};

Map<String, dynamic> _created(String id) => {
  'event_type': 'interaction.created',
  'event_id': '$id-created',
  'interaction': _hop(id, status: 'in_progress'),
};

Map<String, dynamic> _completed(String id, {String? token, String? status}) => {
  'event_type': 'interaction.completed',
  'event_id': '$id-completed',
  'interaction': _hop(
    id,
    status: status ?? (token == null ? 'completed' : 'requires_continuation'),
    token: token,
  ),
};

Map<String, dynamic> _checkpoint(String id, String token) => {
  'event_type': 'interaction.status_update',
  'event_id': 'event-for-$token',
  'interaction_id': id,
  'status': 'in_progress',
  'continuation_token': token,
};

Map<String, dynamic> _delta(String text) => {
  'event_type': 'step.delta',
  'index': 0,
  'delta': {'type': 'text', 'text': text},
};

List<int> _sse(Map<String, dynamic> event) =>
    utf8.encode('data: ${jsonEncode(event)}\n\n');

http.StreamedResponse _stream(
  List<Map<String, dynamic>> events, {
  Exception? error,
}) => http.StreamedResponse(
  (() async* {
    for (final event in events) {
      yield _sse(event);
    }
    if (error != null) throw error;
  })(),
  200,
);

http.StreamedResponse _jsonResponse(Map<String, dynamic> body) =>
    http.StreamedResponse(Stream.value(utf8.encode(jsonEncode(body))), 200);

class _PendingCredentials implements AuthProvider {
  final requested = Completer<void>();
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    requested.complete();
    return credentials.future;
  }
}

GoogleAIClient _client(
  http.Client transport, {
  Duration? timeout,
  AuthProvider? authProvider,
}) {
  final client = GoogleAIClient(
    config: GoogleAIConfig(
      interactionsApiVersion: ApiVersion.v1,
      timeout: timeout ?? const Duration(minutes: 2),
      authProvider: authProvider,
    ),
    httpClient: transport,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  for (final stored in [true, false]) {
    test('merges unary output and usage with store=$stored', () async {
      final bodies = <Map<String, dynamic>>[];
      final client = _client(
        MockClient((request) async {
          expect(request.url.path, '/v1/interactions');
          bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
          final body = bodies.length == 1
              ? _hop(
                  'hop-1',
                  status: 'requires_continuation',
                  token: 'next-token',
                  steps: [
                    _userStep,
                    _output('Before tools. '),
                    {
                      'type': 'function_call',
                      'id': 'call-1',
                      'name': 'lookup',
                      'arguments': {'query': 'induction'},
                    },
                    _output('First '),
                  ],
                  fields: {
                    'input': 'Original prompt',
                    'previous_interaction_id': 'older-interaction',
                    'created': '2026-11-27T00:00:00Z',
                    'usage': {
                      'total_input_tokens': 10,
                      'total_output_tokens': 3,
                      'total_tokens': 13,
                      'input_tokens_by_modality': [
                        {'modality': 'text', 'tokens': 10},
                      ],
                      'grounding_tool_count': [
                        {'type': 'google_search', 'count': 1},
                      ],
                    },
                  },
                )
              : _hop(
                  'hop-2',
                  steps: [
                    _userStep,
                    {'type': 'thought'},
                    _output('second.'),
                  ],
                  fields: {
                    'previous_interaction_id': 'hop-1',
                    'created': '2026-11-28T00:00:00Z',
                    'continuation_ids': ['hop-1', 'hop-2'],
                    'usage': {
                      'initial_input_tokens': 999,
                      'total_input_tokens': 20,
                      'total_output_tokens': 2,
                      'total_tokens': 22,
                      'input_tokens_by_modality': [
                        {'modality': 'text', 'tokens': 20},
                      ],
                      'grounding_tool_count': [
                        {'type': 'google_search', 'count': 2},
                      ],
                    },
                  },
                );
          return http.Response(jsonEncode(body), 200);
        }),
      );

      final result = await client.interactions.create(
        model: _model,
        input: _input,
        generationConfig: _generation,
        previousInteractionId: 'older-interaction',
        store: stored,
        automaticContinuation: true,
      );

      expect(bodies, hasLength(2));
      expect(bodies[0], {
        'model': _model,
        'input': 'Original prompt',
        'generation_config': {'max_output_tokens': 131072},
        'previous_interaction_id': 'older-interaction',
        'store': stored,
      });
      expect(bodies[1], {
        'model': _model,
        if (!stored) 'input': 'Original prompt',
        'generation_config': {'max_output_tokens': 131072},
        'previous_interaction_id': stored ? 'hop-1' : 'older-interaction',
        'continuation_token': 'next-token',
        'store': stored,
      });
      expect(result.id, 'hop-2');
      expect(result.previousInteractionId, 'older-interaction');
      expect(result.created, DateTime.utc(2026, 11, 27));
      expect(result.input?.toJson(), 'Original prompt');
      expect(result.outputText, 'First second.');
      expect(result.text, 'Before tools. First second.');
      expect(result.steps!.whereType<UserInputStep>(), hasLength(1));
      expect(result.continuationIds, ['hop-1', 'hop-2']);
      expect(result.toJson()['continuation_ids'], ['hop-1', 'hop-2']);
      expect(result.usage?.totalTokens, 35);
      expect(result.usage?.initialInputTokens, 10);
      expect(result.usage?.totalInputTokens, 30);
      expect(result.usage?.totalOutputTokens, 5);
      expect(result.usage?.inputTokensByModality?.single.tokens, 30);
      expect(result.usage?.groundingToolCount?.single.count, 3);
    });
  }

  test(
    'a later hop cannot set initial input usage for an unknown first hop',
    () async {
      var requests = 0;
      final client = _client(
        MockClient((_) async {
          requests++;
          final body = requests == 1
              ? _hop('first', status: 'requires_continuation', token: 'token')
              : _hop(
                  'second',
                  fields: {
                    'usage': {'initial_input_tokens': 16, 'total_tokens': 20},
                  },
                );
          return http.Response(jsonEncode(body), 200);
        }),
      );

      final result = await client.interactions.create(
        model: _model,
        automaticContinuation: true,
      );
      expect(requests, 2);
      expect(result.usage?.initialInputTokens, isNull);
      expect(result.usage?.totalTokens, 20);
    },
  );

  for (final stored in [true, false]) {
    test(
      'a failed later unary hop exposes partial output with store=$stored',
      () async {
        final bodies = <Map<String, dynamic>>[];
        final client = _client(
          MockClient((request) async {
            bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
            if (bodies.length == 2) {
              return http.Response('{"error":{"message":"Invalid hop"}}', 400);
            }
            return http.Response(
              jsonEncode(
                _hop(
                  'token-owner',
                  status: 'requires_continuation',
                  token: 'resume-token',
                  steps: [_output('Billed output')],
                ),
              ),
              200,
            );
          }),
        );

        await expectLater(
          client.interactions.create(
            model: _model,
            input: _input,
            continuationToken: 'caller-seed',
            previousInteractionId: 'caller-owner',
            store: stored,
            automaticContinuation: true,
          ),
          throwsA(
            isA<InteractionContinuationInterruptedException>()
                .having((error) => error.cause, 'cause', isA<ApiException>())
                .having(
                  (error) => error.partialInteraction?.outputText,
                  'partial output',
                  'Billed output',
                )
                .having(
                  (error) => error.continuationToken,
                  'resume token',
                  'resume-token',
                )
                .having(
                  (error) => error.interactionId,
                  'resume owner',
                  stored ? 'token-owner' : null,
                ),
          ),
        );
        expect(bodies, hasLength(2));
        expect(bodies.first['previous_interaction_id'], 'caller-owner');
        expect(bodies.first['continuation_token'], 'caller-seed');
        expect(bodies.first['input'], 'Original prompt');
      },
    );
  }

  for (final token in [null, '', 'caller-seed']) {
    test(
      'stops at a missing or unchanged unary continuation token ($token)',
      () async {
        var requests = 0;
        final client = _client(
          MockClient((_) async {
            requests++;
            return http.Response(
              jsonEncode(
                _hop('hop', status: 'requires_continuation', token: token),
              ),
              200,
            );
          }),
        );
        final result = await client.interactions.create(
          model: _model,
          continuationToken: 'caller-seed',
          automaticContinuation: true,
        );
        expect(requests, 1);
        expect(result.status, InteractionStatus.requiresContinuation);
        expect(result.continuationToken, token);
      },
    );
  }

  test(
    'preserves one request by default and delegates background continuation',
    () async {
      var requests = 0;
      final client = _client(
        MockClient((_) async {
          requests++;
          return http.Response(
            jsonEncode(
              _hop('manual', status: 'requires_continuation', token: 'token'),
            ),
            200,
          );
        }),
      );
      final manual = await client.interactions.create(model: _model);
      expect(manual.continuationIds, isNull);
      expect(requests, 1);
      final background = await client.interactions.create(
        model: _model,
        background: true,
        automaticContinuation: true,
      );
      expect(background.continuationIds, isNull);
      expect(requests, 2);
    },
  );

  test(
    'unary abort after the first hop stops automatic continuation',
    () async {
      var requests = 0;
      final abort = Completer<void>();
      final client = _client(
        MockClient((_) async {
          requests++;
          abort.complete();
          return http.Response(
            jsonEncode(
              _hop('first', status: 'requires_continuation', token: 'next'),
            ),
            200,
          );
        }),
      );
      await expectLater(
        client.interactions.create(
          model: _model,
          automaticContinuation: true,
          abortTrigger: abort.future,
        ),
        throwsA(isA<AbortedException>()),
      );
      expect(requests, 1);
    },
  );

  test('abort settles even while the first unary send ignores it', () async {
    var requests = 0;
    final pendingSend = Completer<http.StreamedResponse>();
    final sent = Completer<http.Abortable>();
    final abort = Completer<void>();
    final client = _client(
      MockClient.streaming((request, _) {
        requests++;
        sent.complete(request as http.Abortable);
        return pendingSend.future;
      }),
    );
    final result = client.interactions.create(
      model: _model,
      automaticContinuation: true,
      abortTrigger: abort.future,
    );
    final aborted = expectLater(
      result.timeout(const Duration(seconds: 1)),
      throwsA(isA<AbortedException>()),
    );
    final transport = await sent.future;
    abort.complete();
    await transport.abortTrigger!;
    await aborted;

    pendingSend.complete(_jsonResponse(_hop('late-completed')));
    await Future<void>.delayed(Duration.zero);
    expect(requests, 1);
  });

  test('deadline settles while a later unary send ignores abort', () async {
    var requests = 0;
    final pendingSend = Completer<http.StreamedResponse>();
    final sent = Completer<http.Abortable>();
    final client = _client(
      MockClient.streaming((request, _) async {
        requests++;
        if (requests == 1) {
          return _jsonResponse(
            _hop(
              'first',
              status: 'requires_continuation',
              token: 'next',
              steps: [_output('Partial output')],
            ),
          );
        }
        sent.complete(request as http.Abortable);
        return pendingSend.future;
      }),
      timeout: const Duration(milliseconds: 300),
    );
    final result = client.interactions.create(
      model: _model,
      automaticContinuation: true,
    );
    final deadline = expectLater(
      result.timeout(const Duration(seconds: 2)),
      throwsA(
        isA<InteractionContinuationInterruptedException>()
            .having((error) => error.cause, 'cause', isA<TimeoutException>())
            .having(
              (error) => error.partialInteraction?.outputText,
              'partial output',
              'Partial output',
            )
            .having((error) => error.continuationToken, 'token', 'next'),
      ),
    );
    final transport = await sent.future;
    await deadline;
    await transport.abortTrigger!;

    pendingSend.completeError(http.ClientException('Late transport error'));
    await Future<void>.delayed(Duration.zero);
    expect(requests, 2);
  });

  test('a late terminal response body cannot undo a unary abort', () async {
    var requests = 0;
    final abort = Completer<void>();
    final bodyStarted = Completer<void>();
    final bodyCancelled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: bodyStarted.complete,
      onCancel: bodyCancelled.complete,
    );
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return http.StreamedResponse(body.stream, 200);
      }),
    );
    final result = client.interactions.create(
      model: _model,
      automaticContinuation: true,
      abortTrigger: abort.future,
    );
    final aborted = expectLater(
      result.timeout(const Duration(seconds: 1)),
      throwsA(isA<AbortedException>()),
    );
    await bodyStarted.future;
    abort.complete();
    await aborted;
    await bodyCancelled.future.timeout(const Duration(seconds: 1));
    expect(body.hasListener, isFalse);
    body.add(utf8.encode(jsonEncode(_hop('late-completed'))));
    await body.close();
    expect(requests, 1);
  });

  test('a unary deadline cancels an idle response-body subscription', () async {
    final bodyStarted = Completer<void>();
    final bodyCancelled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: bodyStarted.complete,
      onCancel: bodyCancelled.complete,
    );
    final client = _client(
      MockClient.streaming(
        (_, _) async => http.StreamedResponse(body.stream, 200),
      ),
      timeout: const Duration(milliseconds: 300),
    );
    final deadline = expectLater(
      client.interactions.create(model: _model, automaticContinuation: true),
      throwsA(isA<TimeoutException>()),
    );
    await bodyStarted.future;
    await deadline;
    await bodyCancelled.future.timeout(const Duration(seconds: 1));
    expect(body.hasListener, isFalse);
    await body.close();
  });

  test(
    'credentials resolving after a unary deadline cannot start transport',
    () async {
      final provider = _PendingCredentials();
      var requests = 0;
      final client = _client(
        MockClient((_) async {
          requests++;
          return http.Response(jsonEncode(_hop('unexpected')), 200);
        }),
        authProvider: provider,
        timeout: const Duration(milliseconds: 300),
      );
      final result = client.interactions.create(
        model: _model,
        automaticContinuation: true,
      );
      final deadline = expectLater(
        result.timeout(const Duration(seconds: 2)),
        throwsA(isA<TimeoutException>()),
      );
      await provider.requested.future;
      await deadline;

      provider.credentials.complete(const NoAuthCredentials());
      await Future<void>.delayed(Duration.zero);
      expect(requests, 0);
    },
  );

  test(
    'malformed later unary response retains the partial interaction',
    () async {
      var requests = 0;
      final client = _client(
        MockClient((_) async {
          requests++;
          final body = requests == 1
              ? _hop(
                  'first',
                  status: 'requires_continuation',
                  token: 'next',
                  steps: [_output('Partial')],
                )
              : {'id': 17, 'status': 'completed'};
          return http.Response(jsonEncode(body), 200);
        }),
      );
      await expectLater(
        client.interactions.create(model: _model, automaticContinuation: true),
        throwsA(
          isA<InteractionContinuationInterruptedException>()
              .having((error) => error.cause, 'cause', isA<FormatException>())
              .having(
                (error) => error.partialInteraction?.outputText,
                'partial output',
                'Partial',
              ),
        ),
      );
      expect(requests, 2);
    },
  );

  test(
    'continues SSE and retries a dropped seed with the same token owner',
    () async {
      final bodies = <Map<String, dynamic>>[];
      final client = _client(
        MockClient.streaming((request, data) async {
          bodies.add(
            jsonDecode(await http.ByteStream(data).bytesToString())
                as Map<String, dynamic>,
          );
          expect(request.url.path, '/v1/interactions');
          return switch (bodies.length) {
            1 => _stream([
              _created('first'),
              _delta('A'),
              _checkpoint('first', 'checkpoint'),
            ], error: http.ClientException('First disconnect')),
            2 => _stream([
              _created('second-attempt'),
            ], error: http.ClientException('Second disconnect')),
            3 => _stream([_created('final'), _delta('B'), _completed('final')]),
            _ => throw StateError('Unexpected continuation request'),
          };
        }),
      );

      final events = await client.interactions
          .createStream(
            model: _model,
            input: _input,
            automaticContinuation: true,
          )
          .toList();

      expect(bodies, hasLength(3));
      expect(bodies.first['input'], 'Original prompt');
      expect(bodies[1], {
        'model': _model,
        'continuation_token': 'checkpoint',
        'previous_interaction_id': 'first',
        'stream': true,
      });
      expect(bodies[2], bodies[1]);
      expect(events.map((event) => event.eventId), [
        'first-created',
        null,
        'event-for-checkpoint',
        'second-attempt-created',
        'final-created',
        null,
        'final-completed',
      ]);
      expect(
        events.whereType<StepDeltaEvent>().map(
          (event) => (event.delta as TextDelta).text,
        ),
        ['A', 'B'],
      );
    },
  );

  test('never replays output consumed after an SSE checkpoint', () async {
    var requests = 0;
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return _stream([
          _created('first'),
          _checkpoint('first', 'checkpoint'),
          _delta('already yielded'),
          _checkpoint('first', 'checkpoint'),
        ], error: http.ClientException('Disconnect'));
      }),
    );
    final events = <InteractionEvent>[];
    final stream = client.interactions.createStream(
      model: _model,
      automaticContinuation: true,
    );
    await expectLater(
      stream.forEach(events.add),
      throwsA(
        isA<InteractionContinuationInterruptedException>()
            .having((error) => error.interactionId, 'checkpoint owner', 'first')
            .having((error) => error.continuationToken, 'token', 'checkpoint')
            .having((error) => error.continuationIds, 'hop ids', ['first']),
      ),
    );
    expect(requests, 1);
    expect(events.whereType<StepDeltaEvent>(), hasLength(1));
  });

  test('stateless SSE keeps the prompt at a terminal checkpoint', () async {
    final bodies = <Map<String, dynamic>>[];
    final client = _client(
      MockClient.streaming((_, data) async {
        bodies.add(
          jsonDecode(await http.ByteStream(data).bytesToString())
              as Map<String, dynamic>,
        );
        return bodies.length == 1
            ? _stream([
                _created('first'),
                _checkpoint('first', 'next'),
                _delta('First'),
                _completed('first', token: 'next'),
              ])
            : _stream([_delta(' second'), _completed('next-hop')]);
      }),
    );
    final output = await client.interactions
        .createStream(
          model: _model,
          input: _input,
          generationConfig: _generation,
          store: false,
          automaticContinuation: true,
        )
        .where((event) => event is StepDeltaEvent)
        .cast<StepDeltaEvent>()
        .toList();

    expect(bodies, hasLength(2));
    expect(bodies.last, {...bodies.first, 'continuation_token': 'next'});
    expect(output.map((event) => (event.delta as TextDelta).text), [
      'First',
      ' second',
    ]);
  });

  test(
    'malformed SSE checkpoint payload retains the earlier safe token',
    () async {
      var requests = 0;
      final client = _client(
        MockClient.streaming((_, _) async {
          requests++;
          return _stream([
            _created('first'),
            _checkpoint('first', 'safe-token'),
            {..._checkpoint('first', 'malformed-token'), 'usage': false},
          ]);
        }),
      );
      await expectLater(
        client.interactions
            .createStream(model: _model, automaticContinuation: true)
            .drain<void>(),
        throwsA(
          isA<InteractionContinuationInterruptedException>()
              .having((error) => error.cause, 'cause', isA<FormatException>())
              .having(
                (error) => error.continuationToken,
                'safe token',
                'safe-token',
              ),
        ),
      );
      expect(requests, 1);
    },
  );

  for (final status in ['queued', 'paused_by_policy']) {
    test('records $status without automatically resuming decode', () async {
      var requests = 0;
      final client = _client(
        MockClient.streaming((_, _) async {
          requests++;
          return _stream([
            _created('first'),
            {..._checkpoint('first', 'token'), 'status': status},
          ]);
        }),
      );
      final events = await client.interactions
          .createStream(model: _model, automaticContinuation: true)
          .toList();
      final update = events.last as InteractionStatusUpdateEvent;
      expect(update.unrecognizedStatus, status);
      expect(update.toJson()['status'], status);
      expect(requests, 1);
    });
  }

  test('EOF after output beyond a checkpoint is an interruption', () async {
    var requests = 0;
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return _stream([
          _created('first'),
          _checkpoint('first', 'safe-token'),
          _delta('Output after checkpoint'),
        ]);
      }),
    );
    final events = <InteractionEvent>[];
    await expectLater(
      client.interactions
          .createStream(model: _model, automaticContinuation: true)
          .forEach(events.add),
      throwsA(
        isA<InteractionContinuationInterruptedException>()
            .having((error) => error.cause, 'cause', isA<StreamException>())
            .having(
              (error) => error.continuationToken,
              'safe token',
              'safe-token',
            ),
      ),
    );
    expect(events.whereType<StepDeltaEvent>(), hasLength(1));
    expect(requests, 1);
  });

  test(
    'drops late output after a terminal SSE snapshot before resuming',
    () async {
      var requests = 0;
      final client = _client(
        MockClient.streaming((_, _) async {
          requests++;
          return requests == 1
              ? _stream([_completed('first', token: 'next'), _delta('Once')])
              : _stream([_delta('Once'), _completed('next-hop')]);
        }),
      );
      final events = await client.interactions
          .createStream(model: _model, automaticContinuation: true)
          .toList();
      expect(requests, 2);
      expect(
        events.whereType<StepDeltaEvent>().map(
          (event) => (event.delta as TextDelta).text,
        ),
        ['Once'],
      );
    },
  );

  test('keeps an error received after a terminal SSE snapshot', () async {
    var requests = 0;
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return _stream([
          _completed('first', token: 'next'),
          {
            'event_type': 'error',
            'error': {'code': 'server_fault', 'message': 'Late error'},
          },
        ]);
      }),
    );
    final events = await client.interactions
        .createStream(model: _model, automaticContinuation: true)
        .toList();
    expect(requests, 1);
    expect(events.whereType<ErrorEvent>().single.error?.message, 'Late error');
  });

  test('a terminal snapshot clears a previous SSE checkpoint', () async {
    var requests = 0;
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return _stream([
          _created('first'),
          _checkpoint('first', 'old-token'),
          _completed('first', status: 'requires_continuation'),
        ]);
      }),
    );
    final result = await client.interactions
        .createStream(model: _model, automaticContinuation: true)
        .toList();
    expect(requests, 1);
    expect(
      (result.last as InteractionCompletedEvent).interaction.continuationToken,
      isNull,
    );
  });

  test('caps SSE reconnects when the caller token makes no progress', () async {
    var requests = 0;
    final client = _client(
      MockClient.streaming((_, data) async {
        requests++;
        final body =
            jsonDecode(await http.ByteStream(data).bytesToString()) as Map;
        expect(body['continuation_token'], 'caller-token');
        expect(body['previous_interaction_id'], 'caller-owner');
        return _stream([
          _created('attempt-$requests'),
        ], error: http.ClientException('Disconnect'));
      }),
    );
    await expectLater(
      client.interactions
          .createStream(
            model: _model,
            previousInteractionId: 'caller-owner',
            continuationToken: 'caller-token',
            automaticContinuation: true,
          )
          .drain<void>(),
      throwsA(isA<http.ClientException>()),
    );
    expect(requests, 4);
  });

  test(
    'subscription cancellation at a completed hop prevents further requests',
    () async {
      var requests = 0;
      final client = _client(
        MockClient.streaming((_, _) async {
          requests++;
          return _stream([_completed('first', token: 'next')]);
        }),
      );
      await client.interactions
          .createStream(model: _model, automaticContinuation: true)
          .take(1)
          .drain<void>();
      expect(requests, 1);
    },
  );

  test('cancelling a stalled second hop releases the transport', () async {
    var requests = 0;
    final abortable = Completer<http.Abortable>();
    final stalledResponse = Completer<http.StreamedResponse>();
    final client = _client(
      MockClient.streaming((request, _) async {
        requests++;
        if (requests == 1) {
          return _stream([_completed('first', token: 'next')]);
        }
        abortable.complete(request as http.Abortable);
        return stalledResponse.future;
      }),
    );
    final subscription = client.interactions
        .createStream(model: _model, automaticContinuation: true)
        .listen((_) {});
    addTearDown(() async {
      stalledResponse.complete(_stream([]));
      await subscription.cancel();
    });
    final pending = await abortable.future;
    await subscription.cancel().timeout(const Duration(seconds: 1));
    await pending.abortTrigger!.timeout(const Duration(seconds: 1));
    expect(requests, 2);
  });

  test('aborting at an SSE boundary never starts the next hop', () async {
    var requests = 0;
    final abort = Completer<void>();
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return _stream([_completed('first', token: 'next')]);
      }),
    );
    await expectLater(
      client.interactions
          .createStream(
            model: _model,
            automaticContinuation: true,
            abortTrigger: abort.future,
          )
          .forEach((_) => abort.complete()),
      throwsA(isA<AbortedException>()),
    );
    expect(requests, 1);
  });

  test('a whole-call deadline interrupts a pending continuation hop', () async {
    var requests = 0;
    final never = Completer<http.StreamedResponse>();
    final client = _client(
      MockClient.streaming((_, _) async {
        requests++;
        return requests == 1
            ? _stream([_completed('first', token: 'next')])
            : never.future;
      }),
      timeout: const Duration(milliseconds: 300),
    );
    await expectLater(
      client.interactions
          .createStream(model: _model, automaticContinuation: true)
          .drain<void>(),
      throwsA(
        isA<InteractionContinuationInterruptedException>()
            .having(
              (error) => error.cause,
              'deadline cause',
              isA<TimeoutException>(),
            )
            .having((error) => error.continuationToken, 'resume token', 'next'),
      ),
    );
    expect(requests, 2);
  });
}
