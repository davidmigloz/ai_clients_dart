import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

Map<String, dynamic> _session([String status = 'idle']) {
  final original = agentSessionWireFixtures
      .singleWhere((f) => f.schema == 'SessionResource')
      .minimal;
  return jsonDecode(jsonEncode(original)) as Map<String, dynamic>
    ..['id'] = 'session'
    ..['status'] = status;
}

Map<String, dynamic> _state(String id, [String status = 'idle']) => {
  'type': status == 'failed' ? 'agent.session.failed' : 'agent.session.idle',
  'event_id': id,
  'session': _session(status),
};
Map<String, dynamic> _turn(
  String id,
  String kind, {
  String turnId = 'root',
  String? child,
}) => {
  'type': 'agent.session.turn.$kind',
  'event_id': id,
  'session_id': 'session',
  'turn_id': turnId,
  if (kind != 'created') 'usage': null,
  'turn': {
    'object': 'agent.session.turn',
    'id': turnId,
    'session_id': 'session',
    'agent_id': 'agent',
    'subagent_id': child,
    'created_at': 0,
    'started_at': null,
    'completed_at': kind == 'created' ? null : 1,
    'status': kind == 'created' ? 'queued' : kind,
    'error': null,
    'usage': null,
  },
};
Map<String, dynamic> _delta(String id, [String text = 'text']) => {
  'type': 'agent.session.turn.output_text.delta',
  'event_id': id,
  'session_id': 'session',
  'turn_id': 'root',
  'item_id': 'message',
  'content_index': 0,
  'output_index': 0,
  'delta': text,
};

void main() {
  test(
    'lazy immutable capture, validated subscription readiness and stable header precedence',
    () async {
      final t = _Transport();
      final ready = Completer<http.StreamedResponse>();
      t.observe = (_) => ready.future;
      final client = _client(t);
      final content = [
        AgentSessionInputContent.inputText(text: 'PRIVATE-first'),
      ];
      final messages = [AgentSessionInputMessage(content: content)];
      final headers = {
        'IdEmPoTeNcY-KeY': 'header-key',
        'X-Captured': 'at-construction',
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.items(messages),
        idempotencyKey: 'named-key',
        additionalHeaders: headers,
      );
      content.clear();
      messages.clear();
      headers.clear();
      expect(t.calls, isEmpty);
      expect(run.toString(), isNot(contains('PRIVATE')));
      final starting = run.start();
      await _until(() => t.calls.length == 2);
      expect(t.calls, [
        'GET /v1/agents/sessions/session',
        'GET /v1/agents/sessions/session/events',
      ]);
      expect(t.inputs, isEmpty);
      ready.complete(t.observation());
      await starting;
      expect(t.inputs.single, {
        'events': [
          {
            'type': 'agent.session.input.message',
            'input': [
              {
                'type': 'message',
                'role': 'user',
                'content': [
                  {'type': 'input_text', 'text': 'PRIVATE-first'},
                ],
              },
            ],
          },
        ],
      });
      expect(t.inputRequests.single.headers['idempotency-key'], 'header-key');
      expect(t.inputRequests.single.headers['x-captured'], 'at-construction');
      expect(run.start, throwsStateError);
      await run.close();
      expect(t.canceled, isTrue);
      expect(t.closeCount, 0);
      client.close();
      t.dispose();
    },
  );

  test(
    'text normalizes to user content and generated keys are distinct',
    () async {
      final t = _Transport();
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      final other = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('other'),
      );
      expect(run.inputKey, isNot(other.inputKey));
      await run.start();
      expect(((t.inputs.single['events'] as List).single as Map)['input'], [
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'hello'},
          ],
        },
      ]);
      expect(t.inputRequests.single.headers['idempotency-key'], run.inputKey);
      await run.close();
      await other.close();
      client.close();
      t.dispose();
    },
  );

  for (final status in ['in_progress', 'requires_action', 'failed', 'future']) {
    test('non-idle $status rejects before subscription or input', () async {
      final t = _Transport()..retrieve = (_) async => _json(_session(status));
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      await expectLater(
        run.start(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.cause,
            'local workflow cause',
            isA<StateError>(),
          ),
        ),
      );
      expect(t.calls, ['GET /v1/agents/sessions/session']);
      await run.close();
      client.close();
      t.dispose();
    });
  }

  test(
    'empty helper arrays reject but raw empty message input remains available',
    () async {
      final t = _Transport();
      final client = _client(t);
      expect(
        () => client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.items(const []),
        ),
        throwsFormatException,
      );
      expect(t.calls, isEmpty);
      await client.agents.sessions.events.create(
        'session',
        CreateAgentSessionEventsRequest(
          events: [AgentSessionInput.message(input: const [])],
        ),
      );
      expect(t.inputs, hasLength(1));
      client.close();
      t.dispose();
    },
  );

  test(
    'first root selection ignores initial idle, children and unrelated terminals',
    () async {
      final t = _Transport();
      final client = _client(t);
      final events = [
        _state('idle-before'),
        _turn('child-created', 'created', turnId: 'child', child: 'child'),
        _turn('child-end', 'completed', turnId: 'child', child: 'child'),
        _state('idle-child'),
        _turn('root-created', 'created'),
        _turn('other-end', 'completed', turnId: 'other'),
        _state('idle-unrelated'),
        _turn('root-end', 'completed'),
        _state('idle-final'),
      ];
      t.input = (_) async {
        events.forEach(t.emit);
        return _accepted();
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      final observed = await run.events.toList();
      expect(
        observed.map((e) => e.toJson()['event_id']),
        events.map((e) => e['event_id']),
      );
      expect(run.selectedTurnId, 'root');
      expect(t.canceled, isTrue);
      expect(() => run.events.listen(null), throwsStateError);
      expect(run.nextEvent, throwsStateError);
      expect(
        t.calls.where((c) => !c.startsWith('GET ') && !c.startsWith('POST ')),
        isEmpty,
      );
      expect(t.inputs, hasLength(1));
      expect(
        ((t.inputs.single['events'] as List).single
            as Map<String, dynamic>)['type'],
        'agent.session.input.message',
      );
      client.close();
      t.dispose();
    },
  );

  for (final kind in ['failed', 'cancelled']) {
    test(
      'selected $kind then idle ends observation without inventing success',
      () async {
        final t = _Transport();
        final client = _client(t);
        t.input = (_) async {
          t
            ..emit(_turn('created', 'created'))
            ..emit(_turn('terminal', kind))
            ..emit(_state('idle'));
          return _accepted();
        };
        final run = client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('hello'),
        );
        final events = await run.events.toList();
        expect(events.map((e) => e.type), [
          'agent.session.turn.created',
          'agent.session.turn.$kind',
          'agent.session.idle',
        ]);
        client.close();
        t.dispose();
      },
    );
  }

  test('session.failed ends without a selected root', () async {
    final t = _Transport();
    final client = _client(t);
    t.input = (_) async {
      t.emit(_state('failed', 'failed'));
      return _accepted();
    };
    final run = client.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('hello'),
    );
    expect(await run.nextEvent(), isA<AgentSessionFailedEvent>());
    expect(await run.nextEvent(), isNull);
    expect(run.selectedTurnId, isNull);
    client.close();
    t.dispose();
  });

  for (final phase in ['initial', 'created', 'terminal']) {
    test('EOF at $phase is local observation failure', () async {
      final t = _Transport();
      final client = _client(t);
      t.input = (_) async {
        t.emit(_state('initial'));
        if (phase != 'initial') t.emit(_turn('created', 'created'));
        if (phase == 'terminal') t.emit(_turn('terminal', 'completed'));
        unawaited(t.body.close());
        return _accepted();
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      await expectLater(
        run.events.toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.toString(),
            'private diagnostics',
            isNot(contains('PRIVATE')),
          ),
        ),
      );
      expect(t.inputs, hasLength(1));
      client.close();
      t.dispose();
    });
  }

  test(
    'controlled pulls share one setup and reject concurrent or competing drivers',
    () async {
      final t = _Transport();
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      await run.start();
      final pending = run.nextEvent();
      expect(run.nextEvent, throwsStateError);
      expect(() => run.events.listen(null), throwsStateError);
      t.emit(_delta('first'));
      expect((await pending)!.toJson()['event_id'], 'first');
      final next = run.nextEvent();
      t.emit(_state('last', 'failed'));
      expect(await next, isA<AgentSessionFailedEvent>());
      expect(await run.nextEvent(), isNull);
      expect(await run.nextEvent(), isNull);
      expect(t.inputs, hasLength(1));
      expect(
        t.calls.where((c) => c.endsWith('/events') && c.startsWith('GET')),
        hasLength(1),
      );
      client.close();
      t.dispose();
    },
  );

  test(
    'abort before start exposes original reason and makes no request',
    () async {
      final t = _Transport();
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('PRIVATE-input'),
      );
      final cause = Object();
      run.abort(cause);
      await expectLater(
        run.nextEvent(),
        throwsA(
          isA<AbortedException>()
              .having((e) => e.cause, 'abort cause', same(cause))
              .having((e) => e.stage, 'stage', AbortionStage.beforeRequest)
              .having(
                (e) => e.toString(),
                'private diagnostics',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
      expect(t.calls, isEmpty);
      await run.close();
      client.close();
      t.dispose();
    },
  );

  test('already-completed external abort wins before auth', () async {
    final t = _Transport();
    final client = _client(t);
    final cause = StateError('PRIVATE-abort');
    final external = Completer<void>()..completeError(cause);
    final run = client.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('hello'),
      abortTrigger: external.future,
    );
    await expectLater(
      run.start(),
      throwsA(
        isA<AbortedException>().having(
          (e) => e.cause,
          'external abort cause',
          same(cause),
        ),
      ),
    );
    expect(t.calls, isEmpty);
    client.close();
    t.dispose();
  });

  test(
    'Stream.take cancels pending observation and never backend work',
    () async {
      final t = _Transport();
      final client = _client(t);
      t.input = (_) async {
        t.emit(_state('first'));
        return _accepted();
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      expect(await run.events.take(1).toList(), hasLength(1));
      await _until(() => t.canceled);
      expect(run.isClosed, isTrue);
      expect(t.inputs, hasLength(1));
      expect(t.calls, hasLength(3));
      client.close();
      t.dispose();
    },
  );

  test(
    'cancel while waiting for headers settles and disposes late response',
    () async {
      final t = _Transport();
      final client = _client(t);
      final headers = Completer<http.StreamedResponse>();
      t.observe = (_) => headers.future;
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      final subscription = run.events.listen((_) => fail('No event expected'));
      await _until(() => t.calls.length == 2);
      await subscription.cancel().timeout(const Duration(seconds: 2));
      headers.complete(t.observation());
      await _until(() => t.canceled);
      expect(t.inputs, isEmpty);
      expect(t.closeCount, 0);
      client.close();
      t.dispose();
    },
  );

  for (final limit in ['count', 'bytes']) {
    test(
      'explicit $limit queue overflow fails and releases observation',
      () async {
        final t = _Transport();
        final client = _client(t);
        final run = client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('hello'),
          maxBufferedEvents: limit == 'count' ? 2 : 256,
          maxBufferedBytes: limit == 'bytes' ? 1 : 1024 * 1024,
        );
        await run.start();
        t
          ..emit(_delta('one'))
          ..emit(_delta('two'))
          ..emit(_delta('three'));
        await _until(() => run.isClosed);
        final seen = <AgentSessionEvent>[];
        await expectLater(
          run.events.forEach(seen.add),
          throwsA(isA<StreamException>()),
        );
        expect(seen.length, limit == 'count' ? 2 : 0);
        expect(t.canceled, isTrue);
        expect(t.inputs, hasLength(1));
        client.close();
        t.dispose();
      },
    );
  }

  test(
    'input failure closes the observer and preserves a private explicit API cause',
    () async {
      final t = _Transport();
      final client = _client(t);
      t.input = (_) async => http.StreamedResponse(
        Stream.value(
          utf8.encode(
            '{"error":{"message":"PRIVATE-status","type":"invalid_request_error"}}',
          ),
        ),
        400,
      );
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      await expectLater(
        run.start(),
        throwsA(
          isA<StreamException>()
              .having((e) => e.cause, 'API cause', isA<BadRequestException>())
              .having(
                (e) => e.toString(),
                'private output',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
      expect(t.canceled, isTrue);
      expect(t.inputs, hasLength(1));
      await run.close();
      client.close();
      t.dispose();
    },
  );

  test(
    'configured input retry preserves the exact body and stable input key',
    () async {
      final t = _Transport();
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/v1',
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
            jitter: 0,
          ),
        ),
        httpClient: t,
      );
      t.input = (_) async => t.inputs.length == 1
          ? http.StreamedResponse(
              Stream.value(utf8.encode('{"error":{"message":"retry"}}')),
              429,
            )
          : _accepted();
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
        idempotencyKey: 'input-only',
      );
      await run.start();
      expect(t.inputs, hasLength(2));
      expect(t.inputs.first, t.inputs.last);
      expect(t.inputRequests.map((r) => r.headers['idempotency-key']), [
        'input-only',
        'input-only',
      ]);
      expect(t.calls.where((r) => r.startsWith('GET ')), hasLength(2));
      await run.close();
      client.close();
      t.dispose();
    },
  );

  for (final stage in ['retrieve', 'input']) {
    test(
      'abort pending $stage settles promptly, retains cause and never replays late completion',
      () async {
        final t = _Transport();
        final client = _client(t);
        final gate = Completer<http.StreamedResponse>();
        if (stage == 'retrieve') {
          t.retrieve = (_) => gate.future;
        } else {
          t.input = (_) => gate.future;
        }
        final run = client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('hello'),
        );
        final starting = run.start();
        await _until(() => t.calls.length == (stage == 'retrieve' ? 1 : 3));
        final cause = StateError('PRIVATE-reason');
        final expected = expectLater(
          starting,
          throwsA(
            isA<AbortedException>().having(
              (e) => e.cause,
              'abort cause',
              same(cause),
            ),
          ),
        );
        run.abort(cause);
        await expected.timeout(const Duration(seconds: 2));
        await run.close().timeout(const Duration(seconds: 2));
        gate.complete(stage == 'retrieve' ? _json(_session()) : _accepted());
        await Future<void>.delayed(Duration.zero);
        expect(t.inputs.length, stage == 'retrieve' ? 0 : 1);
        if (stage == 'input') expect(t.canceled, isTrue);
        expect(t.closeCount, 0);
        client.close();
        t.dispose();
      },
    );
  }

  test(
    'Stream cancellation during a pending event pull settles without an error',
    () async {
      final t = _Transport();
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      final subscription = run.events.listen((_) => fail('No event expected'));
      await _until(() => t.inputs.isNotEmpty);
      await subscription.cancel().timeout(const Duration(seconds: 2));
      expect(t.canceled, isTrue);
      expect(t.inputs, hasLength(1));
      client.close();
      t.dispose();
    },
  );

  test(
    'close wakes a pending explicit pull with its local abort outcome',
    () async {
      final t = _Transport();
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      await run.start();
      final expected = expectLater(
        run.nextEvent(),
        throwsA(isA<AbortedException>()),
      );
      await run.close();
      await expected;
      expect(t.canceled, isTrue);
      expect(t.calls, hasLength(3));
      client.close();
      t.dispose();
    },
  );

  test(
    'pause forwards raw observation backpressure and resumes the same run',
    () async {
      final t = _Transport();
      final client = _client(t);
      t.input = (_) async {
        t.emit(_delta('first'));
        return _accepted();
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
        maxBufferedEvents: 1,
      );
      final seen = <String>[];
      final finished = Completer<void>();
      late StreamSubscription<AgentSessionEvent> subscription;
      subscription = run.events.listen(
        (event) {
          seen.add(event.toJson()['event_id'] as String);
          if (seen.length == 1) subscription.pause();
        },
        onError: finished.completeError,
        onDone: finished.complete,
      );
      await _until(() => seen.length == 1);
      await Future<void>.delayed(Duration.zero);
      expect(t.body.isPaused, isTrue);
      t.emit(_delta('second'));
      await Future<void>.delayed(Duration.zero);
      expect(seen, ['first']);
      subscription.resume();
      await _until(() => seen.length == 2);
      t.emit(_state('last', 'failed'));
      await finished.future;
      await subscription.cancel();
      expect(seen, ['first', 'second', 'last']);
      expect(t.inputs, hasLength(1));
      client.close();
      t.dispose();
    },
  );

  test(
    'dedicated observer ownership stays separate from borrowed HTTP',
    () async {
      final t = _Transport();
      final owned = _OwnedObserver();
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/v1',
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: t,
        streamClientFactory: () => owned,
      );
      t.input = (_) async {
        owned.emit(_state('last', 'failed'));
        return _accepted();
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      expect(await run.events.toList(), hasLength(1));
      expect(owned.closeCount, 1);
      expect(owned.canceled, isTrue);
      expect(t.closeCount, 0);
      client.close();
      expect(t.closeCount, 0);
      t.dispose();
      owned.dispose();
    },
  );

  test(
    'client close after helper capture prevents all later admission',
    () async {
      final t = _Transport();
      final client = _client(t);
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      client.close();
      await expectLater(
        run.start(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.cause,
            'closed-client cause',
            isA<StateError>(),
          ),
        ),
      );
      expect(t.calls, isEmpty);
      expect(t.closeCount, 0);
      t.dispose();
    },
  );

  test(
    'typed provider exceptions remain explicit causes without printable secrets',
    () async {
      final t = _Transport();
      final provider = _ThrowProvider();
      final client = OpenAIClient(
        config: OpenAIConfig(authProvider: provider),
        httpClient: t,
      );
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      await expectLater(
        run.start(),
        throwsA(
          isA<StreamException>()
              .having(
                (e) => e.cause,
                'original provider error',
                same(provider.error),
              )
              .having(
                (e) => e.toString(),
                'private diagnostic',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
      expect(provider.calls, 1);
      expect(t.calls, isEmpty);
      await run.close();
      client.close();
      t.dispose();
    },
  );

  test(
    'future opaque events without IDs remain original and have no invented dedup identity',
    () async {
      final t = _Transport();
      final client = _client(t);
      const future = {
        'type': 'future.event',
        'opaque': ['future-value'],
      };
      t.input = (_) async {
        t
          ..emit(future)
          ..emit(future)
          ..emit(_state('last', 'failed'));
        return _accepted();
      };
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
      );
      final values = await run.events.toList();
      expect(values.take(2).map((e) => e.toJson()), [future, future]);
      expect(values.last, isA<AgentSessionFailedEvent>());
      client.close();
      t.dispose();
    },
  );

  for (final exact in [true, false]) {
    test('encoded UTF8 queue byte bound exact=$exact', () async {
      final t = _Transport();
      final client = _client(t);
      final event = _delta('bytes', 'é🚀');
      final bytes = utf8.encode(jsonEncode(event)).length;
      final run = client.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('hello'),
        maxBufferedBytes: exact ? bytes : bytes - 1,
      );
      await run.start();
      t.emit(event);
      if (exact) {
        expect((await run.nextEvent())!.toJson()['delta'], 'é🚀');
      } else {
        await _until(() => run.isClosed);
        await expectLater(run.nextEvent(), throwsA(isA<StreamException>()));
      }
      await run.close();
      client.close();
      t.dispose();
    });
  }

  test(
    'empty string rejects locally while a raw empty text shape stays available',
    () async {
      final t = _Transport();
      final client = _client(t);
      expect(
        () => client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text(''),
        ),
        throwsFormatException,
      );
      expect(t.calls, isEmpty);
      await client.agents.sessions.events.create(
        'session',
        CreateAgentSessionEventsRequest(
          events: [
            AgentSessionInput.message(
              input: [
                AgentSessionInputMessage(
                  content: [AgentSessionInputContent.inputText(text: '')],
                ),
              ],
            ),
          ],
        ),
      );
      expect(t.inputs, hasLength(1));
      client.close();
      t.dispose();
    },
  );

  for (final late in ['error', 'eof', 'input-failure']) {
    test(
      'source boundary before input acceptance distinguishes late $late',
      () async {
        final t = _Transport();
        final client = _client(t);
        final sessions = _PendingInputSessions(client.agents.sessions);
        final run = sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('hello'),
        );
        final progress = run.events.toList();
        await sessions.observer.inputEntered.future;
        final source = sessions.observer.source
          ..emit(_turn('created', 'created'))
          ..emit(_turn('completed', 'completed'))
          ..emit(_state('idle'));
        expect(source.canceled, isTrue);
        // This injected source intentionally calls a late producer callback even
        // after cancellation, exercising the helper's outcome-origin guard.
        if (late == 'error') {
          source.error(
            const ApiException(message: 'PRIVATE-late-SSE', statusCode: 500),
          );
        }
        if (late == 'eof') source.done();
        if (late == 'input-failure') {
          const error = ApiException(
            message: 'PRIVATE-input-failure',
            statusCode: 400,
          );
          final expected = expectLater(
            progress,
            throwsA(
              isA<StreamException>().having(
                (e) => e.cause,
                'genuine input failure',
                same(error),
              ),
            ),
          );
          sessions.observer.inputAccepted.completeError(error);
          await expected;
        } else {
          sessions.observer.inputAccepted.complete();
          final events = await progress;
          expect(events.map((event) => event.type), [
            'agent.session.turn.created',
            'agent.session.turn.completed',
            'agent.session.idle',
          ]);
        }
        expect(sessions.observer.inputs, 1);
        client.close();
        t.dispose();
      },
    );
  }

  test('recent delivery dedup evicts only the oldest at1024 IDs', () async {
    final t = _Transport();
    final client = _client(t);
    final run = client.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('hello'),
    );
    await run.start();
    for (var index = 0; index < 1025; index++) {
      final next = run.nextEvent();
      t.emit(_delta('$index'));
      expect((await next)!.toJson()['event_id'], '$index');
    }
    final evicted = run.nextEvent();
    t.emit(_delta('0'));
    expect((await evicted)!.toJson()['event_id'], '0');
    final retained = run.nextEvent();
    t
      ..emit(_delta('1024'))
      ..emit(_state('finish', 'failed'));
    expect(await retained, isA<AgentSessionFailedEvent>());
    expect(await run.nextEvent(), isNull);
    client.close();
    t.dispose();
  });
}

OpenAIClient _client(_Transport t) => OpenAIClient(
  config: const OpenAIConfig(
    baseUrl: 'https://fixture.invalid/v1',
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: t,
);
http.StreamedResponse _json(Object value) => http.StreamedResponse(
  Stream.value(utf8.encode(jsonEncode(value))),
  200,
  headers: {'content-type': 'application/json'},
);
http.StreamedResponse _accepted() =>
    http.StreamedResponse(const Stream.empty(), 202);

final class _Transport extends http.BaseClient {
  _Transport() {
    body = StreamController<List<int>>(
      onCancel: () => canceled = true,
      onPause: () => pauses++,
    );
  }
  late final StreamController<List<int>> body;
  final calls = <String>[];
  final inputs = <Map<String, dynamic>>[];
  final inputRequests = <http.BaseRequest>[];
  Future<http.StreamedResponse> Function(http.BaseRequest)? retrieve;
  Future<http.StreamedResponse> Function(http.BaseRequest)? observe;
  Future<http.StreamedResponse> Function(http.BaseRequest)? input;
  bool canceled = false;
  int closeCount = 0;
  int pauses = 0;
  void emit(Object event) =>
      body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  http.StreamedResponse observation() => http.StreamedResponse(
    body.stream,
    200,
    headers: {'content-type': 'text/event-stream'},
  );
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls.add('${request.method} ${request.url.path}');
    if (request.method == 'GET' && request.url.path.endsWith('/events')) {
      return observe?.call(request) ?? observation();
    }
    if (request.method == 'GET') {
      return retrieve?.call(request) ?? _json(_session());
    }
    if (request.method != 'POST' || !request.url.path.endsWith('/events')) {
      throw StateError('Unexpected operation');
    }
    final bytes = await request.finalize().toBytes();
    inputs.add(jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>);
    inputRequests.add(request);
    return input?.call(request) ?? _accepted();
  }

  @override
  void close() => closeCount++;
  void dispose() {
    unawaited(body.close());
  }
}

Future<void> _until(bool Function() predicate) async {
  for (var index = 0; index < 1000; index++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Controlled run fixture did not settle');
}

final class _OwnedObserver extends http.BaseClient {
  _OwnedObserver() {
    body = StreamController<List<int>>(onCancel: () => canceled = true);
  }
  late final StreamController<List<int>> body;
  int closeCount = 0;
  bool canceled = false;
  void emit(Object event) =>
      body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        body.stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
  @override
  void close() => closeCount++;
  void dispose() {
    unawaited(body.close());
  }
}

final class _ThrowProvider implements AuthProvider {
  final error = const ApiException(
    message: 'PRIVATE-provider',
    statusCode: 400,
  );
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    throw error;
  }
}

final class _PendingInputSessions extends AgentSessionsResource {
  _PendingInputSessions(AgentSessionsResource base)
    : observer = _PendingInputEvents(base),
      super(
        config: base.config,
        httpClient: base.httpClient,
        interceptorChain: base.interceptorChain,
        requestBuilder: base.requestBuilder,
      );
  final _PendingInputEvents observer;
  @override
  AgentSessionEventsResource get events => observer;
  @override
  Future<AgentSession> retrieve(
    String sessionId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async => AgentSession.fromJson(_session());
}

final class _PendingInputEvents extends AgentSessionEventsResource {
  _PendingInputEvents(AgentSessionsResource base)
    : super(
        config: base.config,
        httpClient: base.httpClient,
        interceptorChain: base.interceptorChain,
        requestBuilder: base.requestBuilder,
      );
  final source = _LateEventSource();
  final inputEntered = Completer<void>();
  final inputAccepted = Completer<void>();
  int inputs = 0;
  @override
  Stream<AgentSessionEvent> stream(
    String sessionId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
    void Function()? onReady,
  }) {
    source.ready = onReady;
    return source;
  }

  @override
  Future<void> create(
    String sessionId,
    CreateAgentSessionEventsRequest request, {
    String? idempotencyKey,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    inputs++;
    inputEntered.complete();
    return inputAccepted.future;
  }
}

final class _LateEventSource extends Stream<AgentSessionEvent> {
  void Function()? ready;
  void Function(AgentSessionEvent)? data;
  Function? failure;
  void Function()? completed;
  bool canceled = false;
  void emit(Map<String, dynamic> event) =>
      data?.call(AgentSessionEvent.fromJson(event));
  void error(Object error) {
    Function.apply(failure!, [error, StackTrace.current]);
  }

  void done() => completed?.call();
  @override
  StreamSubscription<AgentSessionEvent> listen(
    void Function(AgentSessionEvent)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    data = onData;
    failure = onError;
    completed = onDone;
    scheduleMicrotask(() => ready?.call());
    return _LateEventSubscription(this);
  }
}

final class _LateEventSubscription
    implements StreamSubscription<AgentSessionEvent> {
  _LateEventSubscription(this.source);
  final _LateEventSource source;
  @override
  Future<void> cancel() async {
    source.canceled = true;
  }

  @override
  void onData(void Function(AgentSessionEvent)? handleData) =>
      source.data = handleData;
  @override
  void onError(Function? handleError) => source.failure = handleError;
  @override
  void onDone(void Function()? handleDone) => source.completed = handleDone;
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  bool get isPaused => false;
  @override
  Future<E> asFuture<E>([E? futureValue]) => throw UnsupportedError(
    'Only producer callbacks are used by this local late-event fixture',
  );
}
