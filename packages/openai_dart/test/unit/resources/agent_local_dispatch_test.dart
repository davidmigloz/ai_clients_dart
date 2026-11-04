import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

Map<String, dynamic> _session() =>
    jsonDecode(
            jsonEncode(
              agentSessionWireFixtures
                  .singleWhere((f) => f.schema == 'SessionResource')
                  .minimal,
            ),
          )
          as Map<String, dynamic>
      ..['id'] = 'session'
      ..['status'] = 'idle';
Map<String, dynamic> _turn(String id, String kind, {String turn = 'root'}) => {
  'type': 'agent.session.turn.$kind',
  'event_id': id,
  'session_id': 'session',
  'turn_id': turn,
  if (kind != 'created') 'usage': null,
  'turn': {
    'object': 'agent.session.turn',
    'id': turn,
    'session_id': 'session',
    'agent_id': 'agent',
    'subagent_id': null,
    'created_at': 0,
    'started_at': null,
    'completed_at': kind == 'created' ? null : 1,
    'status': kind == 'created' ? 'queued' : kind,
    'error': null,
    'usage': null,
  },
};
Map<String, dynamic> _call(
  String event, {
  String call = 'call',
  String turn = 'root',
  String name = 'local',
  Object? arguments = const {'number': 2},
  String session = 'session',
  String kind = 'added',
}) => {
  'type': 'agent.session.turn.item.$kind',
  'event_id': event,
  'session_id': session,
  'turn_id': turn,
  'output_index': 0,
  'item': {
    'type': 'function_call',
    'id': 'item-$event',
    'call_id': call,
    'turn_id': turn,
    'name': name,
    'arguments': arguments,
    'status': 'completed',
  },
};
Map<String, dynamic> _idle() => {
  'type': 'agent.session.idle',
  'event_id': 'idle',
  'session': _session(),
};

void main() {
  test(
    'yield-before-execution; input/handler/header capture and separate result key',
    () async {
      final t = _Peer();
      final c = _client(t);
      var invoked = 0;
      final handlers = <String, AgentToolHandler>{
        'local': (args) {
          invoked++;
          return {'answer': args['number']};
        },
      };
      final headers = {'IDEMPOTENCY-KEY': 'PRIVATE-input', 'X-Captured': 'yes'};
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: handlers,
        additionalHeaders: headers,
      );
      handlers.clear();
      headers.clear();
      expect(t.requests, isEmpty);
      expect(await run.nextEvent(), isA<AgentSessionTurnCreatedEvent>());
      final original = await run.nextEvent();
      expect(original, isA<AgentSessionTurnItemAddedEvent>());
      expect(invoked, 0);
      expect(t.results, isEmpty);
      final item =
          (original! as AgentSessionTurnItemAddedEvent).item
              as AgentSessionFunctionCallItemResource;
      expect(
        () => (item.arguments! as Map)['number'] = 99,
        throwsUnsupportedError,
      );
      await _drain(run);
      expect(invoked, 1);
      expect(t.results.single, {
        'type': 'agent.session.input.tool_result',
        'turn_id': 'root',
        'call_id': 'call',
        'success': true,
        'output': '{"answer":2}',
      });
      expect(t.keys.first, 'PRIVATE-input');
      expect(t.keys.last, isNot(t.keys.first));
      expect(t.keys.last, isNotEmpty);
      expect(t.requests.last.headers['x-captured'], 'yes');
      await run.close();
      c.close();
      t.dispose();
    },
  );

  for (final output in <Object?>[
    'text',
    null,
    <String, dynamic>{'x': 1},
    <Map<String, dynamic>>[
      {'type': 'input_text', 'text': 'content'},
    ],
    [AgentSessionInputContent.inputText(text: 'typed')],
    AgentSessionFunctionOutput.text('union'),
  ]) {
    test('supported output ${output.runtimeType}', () async {
      final t = _Peer();
      final c = _client(t);
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {'local': (_) => output},
      );
      await _drain(run);
      expect(t.results.single['success'], true);
      expect(t.results.single.containsKey('output'), true);
      if (output == null) expect(t.results.single['output'], null);
      await run.close();
      c.close();
      t.dispose();
    });
  }

  for (final args in <Object?>[
    '{"number":2}',
    {'number': 2},
  ]) {
    test('string/object arguments normalized ${args.runtimeType}', () async {
      final t = _Peer()..events = [_call('call-event', arguments: args)];
      final c = _client(t);
      Map<String, dynamic>? seen;
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {
          'local': (value) {
            seen = value;
            return null;
          },
        },
      );
      await _drain(run);
      expect(seen, {'number': 2});
      await run.close();
      c.close();
      t.dispose();
    });
  }

  for (final args in <Object?>['PRIVATE-invalid', '[]', 'null', null, [], 3]) {
    test(
      'invalid object arguments submit generic failure ${args.runtimeType} $args',
      () async {
        final t = _Peer()..events = [_call('call-event', arguments: args)];
        final c = _client(t);
        var invoked = 0;
        final observed = <AgentToolError>[];
        final run = c.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('go'),
          toolHandlers: {
            'local': (_) {
              invoked++;
              return null;
            },
          },
          onToolError: (failure) {
            observed.add(failure);
          },
        );
        await _drain(run);
        expect(invoked, 0);
        expect(t.results.single['error'], 'Tool handler failed.');
        expect(t.results.single['success'], false);
        expect(observed.single.stage, AgentToolErrorStage.arguments);
        expect(observed.single.toString(), isNot(contains('PRIVATE')));
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }

  test(
    'async observer awaited; failures retain real private cause and observer failure cannot suppress result',
    () async {
      final t = _Peer();
      final c = _client(t);
      final notify = Completer<void>();
      AgentToolError? seen;
      final cause = StateError('PRIVATE-execution');
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {'local': (_) => throw cause},
        onToolError: (error) async {
          seen = error;
          await notify.future;
          throw StateError('PRIVATE-observer');
        },
      );
      await run.nextEvent();
      await run.nextEvent();
      final continuing = run.nextEvent();
      await _until(() => seen != null);
      expect(t.results, isEmpty);
      expect(seen!.error, same(cause));
      expect(seen!.stage, AgentToolErrorStage.execution);
      expect(
        [seen!.sessionId, seen!.turnId, seen!.callId, seen!.toolName],
        ['session', 'root', 'call', 'local'],
      );
      notify.complete();
      await continuing;
      await _drain(run);
      expect(jsonEncode(t.results), isNot(contains('PRIVATE')));
      expect(t.results.single['error'], 'Tool handler failed.');
      await run.close();
      c.close();
      t.dispose();
    },
  );

  for (final kind in ['cycle', 'number', 'bad-content', 'nonfinite']) {
    test('invalid output $kind uses generic output failure', () async {
      final t = _Peer();
      final c = _client(t);
      AgentToolError? seen;
      final cyclic = <String, dynamic>{};
      cyclic['self'] = cyclic;
      final output = switch (kind) {
        'cycle' => cyclic,
        'number' => 2,
        'bad-content' => [
          {'type': 'PRIVATE-unknown'},
        ],
        _ => {'bad': double.nan},
      };
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {'local': (_) => output},
        onToolError: (e) => seen = e,
      );
      await _drain(run);
      expect(seen!.stage, AgentToolErrorStage.output);
      expect(t.results.single['error'], 'Tool handler failed.');
      await run.close();
      c.close();
      t.dispose();
    });
  }

  test(
    'full call identity dedup independent of event IDs; same call in another turn executes separately',
    () async {
      final t = _Peer()
        ..resultTarget = 2
        ..events = [
          _call('first'),
          _call('duplicate'),
          _call('other', turn: 'child'),
          _call('done-not-dispatched', call: 'done', kind: 'done'),
        ];
      final c = _client(t);
      var invoked = 0;
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {
          'local': (_) {
            invoked++;
            return null;
          },
        },
      );
      await _drain(run);
      expect(invoked, 2);
      expect(t.results.map((r) => r['turn_id']), ['root', 'child']);
      expect(t.keys.toSet().length, 3);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test('unknown handlers remain manual and produce no result', () async {
    final t = _Peer()..events = [_call('unknown', name: 'manual')];
    final c = _client(t);
    final run = c.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('go'),
      toolHandlers: {'local': (_) => null},
    );
    await run.nextEvent();
    expect(await run.nextEvent(), isA<AgentSessionTurnItemAddedEvent>());
    final next = run.nextEvent();
    t.finish();
    await next;
    await _drain(run);
    expect(t.results, isEmpty);
    await run.close();
    c.close();
    t.dispose();
  });

  test(
    'distinct-call count budget fails explicitly without executing the excess call',
    () async {
      final t = _Peer()
        ..events = [_call('a', call: 'a'), _call('b', call: 'b')];
      final c = _client(t);
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        maxToolCalls: 1,
        toolHandlers: {'local': (_) => null},
      );
      await expectLater(_drain(run), throwsA(isA<StreamException>()));
      expect(t.results.length, lessThanOrEqualTo(1));
      expect(t.results.every((result) => result['call_id'] == 'a'), true);
      expect(t.canceled, true);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  for (final stage in ['execution', 'observer']) {
    test(
      'abort during $stage does not synthesize failure or submit late output',
      () async {
        final t = _Peer();
        final c = _client(t);
        final waiting = Completer<Object?>();
        final entered = Completer<void>();
        final run = c.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('go'),
          toolHandlers: {
            'local': (_) {
              if (stage == 'observer') throw StateError('PRIVATE');
              entered.complete();
              return waiting.future;
            },
          },
          onToolError: (_) {
            entered.complete();
            return waiting.future.then<void>((_) {});
          },
        );
        await run.nextEvent();
        await run.nextEvent();
        final next = run.nextEvent();
        await entered.future;
        final checking = expectLater(next, throwsA(isA<AbortedException>()));
        run.abort('PRIVATE-abort');
        await checking;
        waiting.complete('late');
        await Future<void>.delayed(Duration.zero);
        expect(t.results, isEmpty);
        expect(t.canceled, true);
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }

  test(
    'registration race exactly four transport attempts, fixed body/key, exact delays, one handler',
    () async {
      final delays = <int>[];
      final t = _Peer();
      final c = _client(t);
      var invoked = 0;
      t.reply = (attempt) => attempt < 4
          ? _error(
              400,
              'invalid_request_error',
              'Unknown pending tool call: call',
            )
          : _accepted();
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {
          'local': (_) {
            invoked++;
            return null;
          },
        },
      );
      await runZoned(
        () => _drain(run),
        zoneSpecification: ZoneSpecification(
          createTimer: (self, parent, zone, duration, callback) {
            if ([100, 300, 600].contains(duration.inMilliseconds)) {
              delays.add(duration.inMilliseconds);
              return parent.createTimer(zone, Duration.zero, callback);
            }
            return parent.createTimer(zone, duration, callback);
          },
        ),
      );
      expect(delays, [100, 300, 600]);
      expect(t.results.length, 4);
      expect(invoked, 1);
      expect(t.results.map(jsonEncode).toSet().length, 1);
      expect(t.keys.skip(1).toSet().length, 1);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  for (final error in [
    (400, 'other', 'Unknown pending tool call: call'),
    (400, 'invalid_request_error', 'Unknown pending tool call: other'),
    (400, 'invalid_request_error', 'Unknown pending tool call: call '),
    (429, 'invalid_request_error', 'Unknown pending tool call: call'),
    (503, 'invalid_request_error', 'Unknown pending tool call: call'),
  ]) {
    test(
      'unrelated result error $error never general-retries or notifies handler observer',
      () async {
        final t = _Peer()..reply = (_) => _error(error.$1, error.$2, error.$3);
        final c = _client(t);
        var observed = 0;
        final run = c.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('go'),
          toolHandlers: {'local': (_) => null},
          onToolError: (_) {
            observed++;
          },
        );
        await expectLater(
          _drain(run),
          throwsA(
            isA<StreamException>().having(
              (e) => e.cause,
              'HTTPcause',
              isA<ApiException>(),
            ),
          ),
        );
        expect(t.results.length, 1);
        expect(observed, 0);
        expect(t.canceled, true);
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }

  test('abort owns and cancels pending race timer', () async {
    final t = _Peer()
      ..reply = (_) => _error(
        400,
        'invalid_request_error',
        'Unknown pending tool call: call',
      );
    final c = _client(t);
    final timerReady = Completer<void>();
    Timer? held;
    final run = c.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('go'),
      toolHandlers: {'local': (_) => null},
    );
    final progress = runZoned(
      () => _drain(run),
      zoneSpecification: ZoneSpecification(
        createTimer: (self, parent, zone, duration, callback) {
          if (duration.inMilliseconds == 100) {
            held = parent.createTimer(zone, const Duration(days: 1), callback);
            timerReady.complete();
            return held!;
          }
          return parent.createTimer(zone, duration, callback);
        },
      ),
    );
    await timerReady.future;
    final checking = expectLater(progress, throwsA(isA<AbortedException>()));
    run.abort();
    await checking;
    expect(held!.isActive, false);
    expect(t.results.length, 1);
    await run.close();
    c.close();
    t.dispose();
  });

  test(
    'streamed creation lazy canonical identity, snapshots, local metadata absent on wire',
    () async {
      final t = _Peer()..creation = true;
      final c = _client(t);
      final handlers = <String, AgentToolHandler>{'local': (_) => null};
      final request = CreateAgentSessionRequest(
        agentId: 'agent',
        environment: AgentSessionEnvironment.none(),
        input: AgentSessionInitialInput.text('go'),
      );
      final run = c.agents.sessions.createRun(
        request,
        toolHandlers: handlers,
        additionalHeaders: {'IDEMPOTENCY-KEY': 'creation-key'},
      );
      handlers.clear();
      expect(run.observedSessionId, null);
      expect(() => run.sessionId, throwsStateError);
      expect(t.requests, isEmpty);
      await _drain(run);
      expect(run.sessionId, 'session');
      expect(t.creationBody!['stream'], true);
      expect(t.creationBody!.keys, isNot(contains('toolHandlers')));
      expect(t.results.length, 1);
      expect(t.requests.first.method, 'POST');
      expect(t.requests.first.url.path, '/v1/agents/sessions');
      expect(t.keys.first, 'creation-key');
      expect(t.keys.last, isNot('creation-key'));
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test('explicit nonstream creation rejects before auth/HTTP', () {
    final t = _Peer();
    final c = _client(t);
    final request = CreateAgentSessionRequest(
      agentId: 'agent',
      environment: AgentSessionEnvironment.none(),
      input: AgentSessionInitialInput.text('go'),
      stream: false,
    );
    expect(
      () => c.agents.sessions.createRun(
        request,
        toolHandlers: {'local': (_) => null},
      ),
      throwsFormatException,
    );
    expect(t.requests, isEmpty);
    c.close();
    t.dispose();
  });

  for (final mismatch in ['before-identity', 'session', 'turn']) {
    test(
      'dispatch rejects $mismatch routing without invoking or submitting',
      () async {
        final t = _Peer()
          ..creation = mismatch == 'before-identity'
          ..omitIdentity = mismatch == 'before-identity'
          ..events = [
            _call(
              'bad',
              session: mismatch == 'session' ? 'foreign' : 'session',
            ),
          ];
        if (mismatch == 'turn') t.events.single['turn_id'] = 'other';
        final c = _client(t);
        var invoked = 0;
        final run = t.creation
            ? c.agents.sessions.createRun(
                CreateAgentSessionRequest(
                  agentId: 'agent',
                  environment: AgentSessionEnvironment.none(),
                  input: AgentSessionInitialInput.text('go'),
                ),
                toolHandlers: {
                  'local': (_) {
                    invoked++;
                    return null;
                  },
                },
              )
            : c.agents.sessions.stream(
                'session',
                input: AgentSessionInitialInput.text('go'),
                toolHandlers: {
                  'local': (_) {
                    invoked++;
                    return null;
                  },
                },
              );
        await expectLater(_drain(run), throwsA(isA<StreamException>()));
        expect(invoked, 0);
        expect(t.results, isEmpty);
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }
  test('full call dedup survives recent event-window eviction', () async {
    final t = _Peer()
      ..resultTarget = 2
      ..events = [
        _call('first'),
        for (var i = 0; i < 1025; i++)
          {'type': 'future.delivery', 'event_id': 'future-$i'},
        _call('first'),
      ];
    final c = _client(t);
    var invoked = 0;
    final run = c.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('go'),
      maxBufferedEvents: 2048,
      toolHandlers: {
        'local': (_) {
          invoked++;
          return null;
        },
      },
    );
    await run.nextEvent();
    for (var i = 0; i < 1027; i++) {
      await run.nextEvent();
    }
    final tail = run.nextEvent();
    t.finish();
    await tail;
    await _drain(run);
    expect(invoked, 1);
    expect(t.results.length, 1);
    await run.close();
    c.close();
    t.dispose();
  });

  test('stream cancellation after delivered call does not invoke it', () async {
    final t = _Peer();
    final c = _client(t);
    var invoked = 0;
    final run = c.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('go'),
      toolHandlers: {
        'local': (_) {
          invoked++;
          return null;
        },
      },
    );
    await run.events.take(2).drain<void>();
    expect(invoked, 0);
    expect(t.results, isEmpty);
    expect(t.canceled, true);
    c.close();
    t.dispose();
  });

  test(
    'asynchronous callbacks are sequential across multiple call events',
    () async {
      final t = _Peer()
        ..resultTarget = 2
        ..events = [_call('a', call: 'a'), _call('b', call: 'b')];
      final c = _client(t);
      final first = Completer<Object?>();
      var invoked = 0;
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {
          'local': (_) {
            invoked++;
            return invoked == 1 ? first.future : null;
          },
        },
      );
      await run.nextEvent();
      await run.nextEvent();
      final next = run.nextEvent();
      await _until(() => invoked == 1);
      expect(t.results, isEmpty);
      first.complete('first');
      await next;
      expect(invoked, 1);
      await _drain(run);
      expect(invoked, 2);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test('registration race exhaustion stops after four attempts', () async {
    final t = _Peer()
      ..reply = (_) => _error(
        400,
        'invalid_request_error',
        'Unknown pending tool call: call',
      );
    final c = _client(t);
    final run = c.agents.sessions.stream(
      'session',
      input: AgentSessionInitialInput.text('go'),
      toolHandlers: {'local': (_) => null},
    );
    await runZoned(
      () => expectLater(_drain(run), throwsA(isA<StreamException>())),
      zoneSpecification: ZoneSpecification(
        createTimer: (self, parent, zone, duration, callback) {
          return parent.createTimer(
            zone,
            [100, 300, 600].contains(duration.inMilliseconds)
                ? Duration.zero
                : duration,
            callback,
          );
        },
      ),
    );
    expect(t.results.length, 4);
    expect(t.results.map(jsonEncode).toSet().length, 1);
    await run.close();
    c.close();
    t.dispose();
  });

  test('creation abort before start makes no HTTP or local dispatch', () async {
    final t = _Peer()..creation = true;
    final c = _client(t);
    final signal = Completer<void>();
    final run = c.agents.sessions.createRun(
      CreateAgentSessionRequest(
        agentId: 'agent',
        environment: AgentSessionEnvironment.none(),
        input: AgentSessionInitialInput.text('go'),
      ),
      toolHandlers: {'local': (_) => null},
      abortTrigger: signal.future,
    );
    signal.complete();
    await expectLater(run.start(), throwsA(isA<AbortedException>()));
    expect(t.requests, isEmpty);
    expect(t.results, isEmpty);
    await run.close();
    c.close();
    t.dispose();
  });
  for (final create in [false, true]) {
    test(
      'mixed-case defaults and rotating provider preserve input/result keys (create:$create)',
      () async {
        final t = _Peer()
          ..creation = create
          ..reply = (attempt) => attempt < 4
              ? _error(
                  400,
                  'invalid_request_error',
                  'Unknown pending tool call: call',
                )
              : _accepted();
        final provider = _RotatingProvider();
        final c = OpenAIClient(
          httpClient: t,
          config: OpenAIConfig(
            defaultHeaders: const {'Idempotency-Key': 'PRIVATE-default'},
            authProvider: provider,
          ),
        );
        final handlers = <String, AgentToolHandler>{'local': (_) => null};
        final run = create
            ? c.agents.sessions.createRun(
                CreateAgentSessionRequest(
                  agentId: 'agent',
                  environment: AgentSessionEnvironment.none(),
                  input: AgentSessionInitialInput.text('go'),
                ),
                toolHandlers: handlers,
                additionalHeaders: {'Idempotency-Key': 'PRIVATE-explicit'},
              )
            : c.agents.sessions.stream(
                'session',
                input: AgentSessionInitialInput.text('go'),
                toolHandlers: handlers,
                additionalHeaders: {'Idempotency-Key': 'PRIVATE-explicit'},
              );
        await runZoned(
          () => _drain(run),
          zoneSpecification: ZoneSpecification(
            createTimer: (self, parent, zone, duration, callback) =>
                parent.createTimer(
                  zone,
                  [100, 300, 600].contains(duration.inMilliseconds)
                      ? Duration.zero
                      : duration,
                  callback,
                ),
          ),
        );
        expect(t.keys.first, 'PRIVATE-explicit');
        expect(t.keys.skip(1).toSet().length, 1);
        expect(t.keys.last, isNot('PRIVATE-explicit'));
        expect(t.keys.last, isNot(contains('PRIVATE-provider')));
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }
  for (final id in ['', '.', '..']) {
    test(
      'creation path-invalid identity rejects before local effects ($id)',
      () async {
        final t = _Peer()
          ..creation = true
          ..creationSessionId = id
          ..events = [_call('call', session: id)];
        final c = _client(t);
        var invoked = 0;
        final run = c.agents.sessions.createRun(
          CreateAgentSessionRequest(
            agentId: 'agent',
            environment: AgentSessionEnvironment.none(),
            input: AgentSessionInitialInput.text('go'),
          ),
          toolHandlers: {
            'local': (_) {
              invoked++;
              return null;
            },
          },
        );
        await expectLater(_drain(run), throwsA(isA<StreamException>()));
        expect(invoked, 0);
        expect(t.results, isEmpty);
        expect(run.observedSessionId, null);
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }
  for (final entry in {'high': 0xd800, 'low': 0xdc00}.entries) {
    test(
      'creation lone-surrogate ${entry.key} identity rejects before local effects',
      () async {
        final id = String.fromCharCode(entry.value);
        final t = _Peer()
          ..creation = true
          ..creationSessionId = id
          ..events = [_call('call', session: id)];
        final c = _client(t);
        var invoked = 0;
        final run = c.agents.sessions.createRun(
          CreateAgentSessionRequest(
            agentId: 'agent',
            environment: AgentSessionEnvironment.none(),
            input: AgentSessionInitialInput.text('go'),
          ),
          toolHandlers: {
            'local': (_) {
              invoked++;
              return null;
            },
          },
        );
        await expectLater(_drain(run), throwsA(isA<StreamException>()));
        expect(invoked, 0);
        expect(t.results, isEmpty);
        expect(run.observedSessionId, isNull);
        expect(t.requests.length, 1);
        expect(t.requests.single.url.path, '/v1/agents/sessions');
        await run.close();
        c.close();
        t.dispose();
      },
    );
  }
}

Future<void> _drain(AgentSessionRun run) async {
  while (await run.nextEvent() != null) {}
}

Future<void> _until(bool Function() ready) async {
  for (var i = 0; i < 1000; i++) {
    if (ready()) return;
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  throw StateError('Fixture did not settle');
}

OpenAIClient _client(_Peer peer) => OpenAIClient(
  httpClient: peer,
  config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 5)),
);
http.StreamedResponse _accepted() =>
    http.StreamedResponse(const Stream.empty(), 202);
http.StreamedResponse _error(int status, String code, String message) =>
    http.StreamedResponse(
      Stream.value(
        utf8.encode(
          jsonEncode({
            'error': {
              'code': code,
              'type': 'invalid_request_error',
              'message': message,
            },
          }),
        ),
      ),
      status,
      headers: {'content-type': 'application/json'},
    );

final class _Peer extends http.BaseClient {
  final body = StreamController<List<int>>();
  final requests = <http.BaseRequest>[];
  final results = <Map<String, dynamic>>[];
  final keys = <String?>[];
  List<Map<String, dynamic>> events = [_call('call-event')];
  int resultTarget = 1;
  bool creation = false;
  bool omitIdentity = false;
  bool canceled = false;
  Map<String, dynamic>? creationBody;
  String creationSessionId = 'session';
  http.StreamedResponse Function(int attempt)? reply;
  void emit(Object event) =>
      body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  void finish() {
    emit(_turn('complete', 'completed'));
    emit(_idle());
  }

  http.StreamedResponse observation(int status) {
    body.onCancel = () => canceled = true;
    return http.StreamedResponse(
      body.stream,
      status,
      headers: {'content-type': 'text/event-stream'},
    );
  }

  void initial() {
    emit(_turn('root-created', 'created'));
    events.forEach(emit);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.method == 'GET' && request.url.path.endsWith('/events')) {
      return observation(200);
    }
    if (request.method == 'GET') {
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(_session()))),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    final wire =
        jsonDecode(utf8.decode(await request.finalize().toBytes()))
            as Map<String, dynamic>;
    keys.add(request.headers['idempotency-key']);
    if (!request.url.path.endsWith('/events')) {
      creationBody = wire;
      if (!omitIdentity) {
        emit({
          'type': 'agent.session.created',
          'event_id': 'created',
          'session': {..._session(), 'id': creationSessionId},
        });
      }
      initial();
      return observation(201);
    }
    final event = (wire['events'] as List).single as Map<String, dynamic>;
    if (event['type'] == 'agent.session.input.message') {
      initial();
      return _accepted();
    }
    results.add(event);
    final response = reply?.call(results.length) ?? _accepted();
    if (response.statusCode == 202 && results.length >= resultTarget) finish();
    return response;
  }

  void dispose() {
    unawaited(body.close());
  }
}

final class _RotatingProvider implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer PRIVATE-credential-${calls++}',
    'IDEMPOTENCY-KEY': 'PRIVATE-provider-$calls',
  };
}
