import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/agent_session_wire_fixtures.dart';

Map<String, dynamic> _session({
  String status = 'idle',
  List<Map<String, dynamic>> actions = const [],
}) =>
    jsonDecode(
            jsonEncode(
              agentSessionWireFixtures
                  .singleWhere((f) => f.schema == 'SessionResource')
                  .minimal,
            ),
          )
          as Map<String, dynamic>
      ..['id'] = 'session'
      ..['status'] = status
      ..['required_actions'] = actions;
Map<String, dynamic> _turn(
  String status, {
  String id = 'root',
  String? child,
}) => {
  'type': 'agent.session.turn.$status',
  'event_id': 'turn-$id-$status',
  'session_id': 'session',
  'turn_id': id,
  if (status != 'created') 'usage': null,
  'turn': {
    'object': 'agent.session.turn',
    'id': id,
    'session_id': 'session',
    'agent_id': 'agent',
    'subagent_id': child,
    'created_at': 0,
    'started_at': null,
    'completed_at': status == 'created' ? null : 1,
    'status': status == 'created' ? 'queued' : status,
    'error': null,
    'usage': null,
  },
};
Map<String, dynamic> _message(
  String id,
  String text, {
  int index = 0,
  String turn = 'root',
  String? phase = 'final_answer',
  String status = 'completed',
  String kind = 'done',
  List<String>? blocks,
}) => {
  'type': 'agent.session.turn.item.$kind',
  'event_id': 'event-$id-$kind',
  'session_id': 'session',
  'turn_id': turn,
  'output_index': index,
  'item': {
    'type': 'message',
    'id': id,
    'role': 'assistant',
    'turn_id': turn,
    'phase': phase,
    'status': status,
    'content': [
      for (final text in blocks ?? [text])
        {
          'type': 'output_text',
          'text': text,
          'future': {
            'nested': [1],
          },
        },
    ],
    'future_message': {'retained': true},
  },
};
Map<String, dynamic> _state(
  String status, {
  List<Map<String, dynamic>> actions = const [],
}) => {
  'type': 'agent.session.$status',
  'event_id': 'state-$status',
  'session': _session(status: status, actions: actions),
};
AgentSessionRun _run(OpenAIClient c) => c.agents.sessions.stream(
  'session',
  input: AgentSessionInitialInput.text('go'),
);
CreateAgentSessionRequest _request({AgentTextConfig? text}) =>
    CreateAgentSessionRequest(
      agentId: 'agent',
      agent: text == null ? null : AgentSessionAgentConfig(text: text),
      environment: AgentSessionEnvironment.none(),
      input: AgentSessionInitialInput.text('go'),
    );
AgentSessionOutputBinding<int> _binding([int Function(String)? parse]) =>
    AgentSessionOutputBinding<int>(
      format: AgentJsonSchemaFormat(schema: const {'type': 'integer'}),
      parse: parse ?? ((text) => jsonDecode(text) as int),
    );

void main() {
  test(
    'unused finalResult enables same lazy observation, caches successful snapshot and identity',
    () async {
      final t = _Peer()..events = [_message('answer', '42')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c);
      expect(t.requests, isEmpty);
      final first = run.finalResult();
      expect(run.finalResult(), same(first));
      final result = await first;
      expect(result.sessionId, 'session');
      expect(result.turnId, 'root');
      expect(result.turn.status.value, 'completed');
      expect(result.outputText, '42');
      expect(result.finalAnswerText, '42');
      expect(t.requests.length, 3);
      expect(run.isClosed, true);
      expect(await run.finalResult(), same(result));
      expect(t.requests.length, 3);
      expect(t.canceled, true);
      expect(result.messages.clear, throwsUnsupportedError);
      expect(
        () => result.messages.single.rawJson['future_message'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((result.messages.single.content.single.rawJson['future']
                        as Map)['nested']
                    as List)
                .clear(),
        throwsUnsupportedError,
      );
      expect(result.toString(), isNot(contains('42')));
      final copy = AgentSessionRunResult(
        turn: result.turn,
        messages: result.messages,
      );
      expect(copy, result);
      expect(copy.hashCode, result.hashCode);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test(
    'partial controlled cursor then finalResult uses same source and input',
    () async {
      final t = _Peer()..events = [_message('a', 'a'), _message('b', 'b')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.nextEvent();
      await run.nextEvent();
      final result = await run.finalResult();
      expect(result.outputText, 'ab');
      expect(t.inputs, 1);
      expect(t.requests.length, 3);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test(
    'collection before start-only remains valid; completed Stream retrieval adds no HTTP',
    () async {
      final t = _Peer()..events = [_message('a', 'a')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c);
      await run.start();
      run.withResultCollection();
      await run.events.drain<void>();
      expect((await run.finalResult()).outputText, 'a');
      expect(t.requests.length, 3);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test(
    'late enable rejects default progress without poisoning manual consumption',
    () async {
      final t = _Peer()..events = [_message('a', 'a')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c);
      await run.nextEvent();
      expect(run.withResultCollection, throwsStateError);
      expect(run.finalResult, throwsStateError);
      while (await run.nextEvent() != null) {}
      expect(t.inputs, 1);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test(
    'conflicting active progress driver rejects without second setup',
    () async {
      final t = _Peer()..autoTerminal = false;
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      final pull = run.nextEvent();
      expect(run.finalResult, throwsStateError);
      await pull;
      t.finish();
      expect((await run.finalResult()).turnId, 'root');
      expect(t.inputs, 1);
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test(
    'completed root snapshots only, first item ID wins, output order and legacy null phase',
    () async {
      final t = _Peer()
        ..events = [
          _message('last', 'L', index: 9),
          _message('first', 'F', index: 1, phase: null),
          {
            ..._message('last', 'DUP', index: 0),
            'event_id': 'different-delivery',
          },
          _message('commentary', 'PRIVATE-comment', phase: 'commentary'),
          _message('partial', 'partial', status: 'in_progress'),
          _message('child', 'child', turn: 'child'),
          _message('added', 'added', kind: 'added'),
        ];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c);
      final result = await run.finalResult();
      expect(result.messages.map((m) => m.id), ['first', 'last']);
      expect(result.outputText, 'FL');
      expect(result.finalAnswer!.id, 'last');
      expect(result.messages.last.content.single.rawJson, contains('future'));
      expect(
        agentSessionMessagesText([
          AgentSessionAssistantMessageItemResource.fromJson(
            _message('c', 'comment', phase: 'commentary')['item']!
                as Map<String, dynamic>,
          ),
          ...result.messages,
        ]),
        'commentFL',
      );
      await run.close();
      c.close();
      t.dispose();
    },
  );

  test(
    'raw no-text completed result valid; final answer falls back to legacy message',
    () async {
      final t = _Peer();
      final c = OpenAIClient(httpClient: t);
      final empty = await _run(c).finalResult();
      expect(empty.messages, isEmpty);
      expect(empty.outputText, '');
      expect(empty.finalAnswer, null);
      c.close();
      t.dispose();
      final t2 = _Peer()..events = [_message('legacy', 'legacy', phase: null)];
      final c2 = OpenAIClient(httpClient: t2);
      final result = await _run(c2).finalResult();
      expect(result.finalAnswerText, 'legacy');
      c2.close();
      t2.dispose();
    },
  );

  for (final status in ['failed', 'cancelled']) {
    test(
      'native $status returns private typed partial state and caches failure',
      () async {
        final t = _Peer()
          ..events = [_message('partial', 'PRIVATE-answer')]
          ..terminal = status;
        final c = OpenAIClient(httpClient: t);
        final run = _run(c);
        final first = run.finalResult();
        Object? error;
        try {
          await first;
        } catch (e) {
          error = e;
        }
        expect(error, isA<AgentSessionRunResultException>());
        final failure = error! as AgentSessionRunResultException;
        expect(
          failure.reason,
          status == 'failed'
              ? AgentSessionRunResultReason.failed
              : AgentSessionRunResultReason.cancelled,
        );
        expect(failure.turn!.status.value, status);
        expect(failure.messages.single.content.single.text, 'PRIVATE-answer');
        expect(failure.toString(), isNot(contains('PRIVATE')));
        expect(run.finalResult(), same(first));
        await expectLater(first, throwsA(same(failure)));
        expect(t.requests.length, 3);
        c.close();
        t.dispose();
      },
    );
  }

  for (final action in <Map<String, dynamic>>[
    {
      'type': 'function_call',
      'turn_id': 'root',
      'call_id': 'call',
      'name': 'manual',
      'arguments': <String, dynamic>{},
    },
    {'type': 'environment_connection', 'environment_id': 'environment'},
    {
      'type': 'computer_use_approval_request',
      'turn_id': 'root',
      'request_id': 'approval',
      'request': {'type': 'browser_origin', 'url': 'https://example.com'},
    },
    {'type': 'future_action', 'private': 'PRIVATE-action'},
  ]) {
    test(
      'unhandled ${action['type']} fails promptly with detached required actions',
      () async {
        final t = _Peer()
          ..autoTerminal = false
          ..events = [
            _state('requires_action', actions: [action]),
          ];
        final c = OpenAIClient(httpClient: t);
        final run = _run(c);
        await expectLater(
          run.finalResult(),
          throwsA(
            isA<AgentSessionRunResultException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  AgentSessionRunResultReason.requiresAction,
                )
                .having((e) => e.requiredActions.length, 'actions', 1),
          ),
        );
        expect(t.canceled, true);
        expect(t.inputs, 1);
        c.close();
        t.dispose();
      },
    );
  }

  test(
    'session.failed without selected turn is backend failure with no fabricated turn',
    () async {
      final t = _Peer()
        ..emitRoot = false
        ..autoTerminal = false
        ..events = [_state('failed')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c);
      await expectLater(
        run.finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>()
              .having(
                (e) => e.reason,
                'reason',
                AgentSessionRunResultReason.failed,
              )
              .having((e) => e.turn, 'turn', null),
        ),
      );
      c.close();
      t.dispose();
    },
  );

  test(
    'observation failure exposes cause and available partial messages without backend failure',
    () async {
      final t = _Peer()
        ..autoTerminal = false
        ..events = [_message('partial', 'PRIVATE-answer')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.nextEvent();
      await run.nextEvent();
      t.body.addError(StateError('PRIVATE-transport'));
      await expectLater(
        run.finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>()
              .having(
                (e) => e.reason,
                'reason',
                AgentSessionRunResultReason.observationFailed,
              )
              .having((e) => e.messages.length, 'partial', 1)
              .having((e) => e.cause, 'cause', isNotNull)
              .having(
                (e) => e.toString(),
                'private',
                isNot(contains('PRIVATE')),
              ),
        ),
      );
      c.close();
      t.dispose();
    },
  );

  test(
    'aborted partial cursor reports observation outcome and original abort reason',
    () async {
      final t = _Peer()..autoTerminal = false;
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.nextEvent();
      run.abort('PRIVATE-reason');
      await expectLater(
        run.finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>()
              .having(
                (e) => e.reason,
                'reason',
                AgentSessionRunResultReason.observationFailed,
              )
              .having(
                (e) => (e.cause! as AbortedException).cause,
                'abort',
                'PRIVATE-reason',
              ),
        ),
      );
      c.close();
      t.dispose();
    },
  );

  for (final limit in ['count', 'bytes']) {
    test(
      'collection $limit budget fails explicitly, retaining only prior bounded state',
      () async {
        final t = _Peer()
          ..events = [_message('one', 'one'), _message('two', 'two')];
        final c = OpenAIClient(httpClient: t);
        final run = _run(c).withResultCollection(
          maxMessages: limit == 'count' ? 1 : 10,
          maxBytes: limit == 'bytes' ? 1 : 1024 * 1024,
        );
        await expectLater(
          run.finalResult(),
          throwsA(
            isA<AgentSessionRunResultException>().having(
              (e) => e.reason,
              'reason',
              AgentSessionRunResultReason.collectionLimit,
            ),
          ),
        );
        expect(t.canceled, true);
        c.close();
        t.dispose();
      },
    );
  }

  for (final mismatch in [
    'created-outer',
    'created-session',
    'completed-id',
    'completed-session',
    'message-session',
    'message-turn',
  ]) {
    test(
      'conflicting $mismatch never manufactures a usable result identity',
      () async {
        final t = _Peer()
          ..events = [_message('answer', '42')]
          ..transform = (event) {
            if (mismatch == 'created-outer' &&
                event['type'] == 'agent.session.turn.created') {
              event['turn_id'] = 'wrong';
            }
            if (mismatch == 'created-session' &&
                event['type'] == 'agent.session.turn.created') {
              (event['turn']! as Map)['session_id'] = 'wrong';
            }
            if (mismatch == 'completed-id' &&
                event['type'] == 'agent.session.turn.completed') {
              (event['turn']! as Map)['id'] = 'wrong';
            }
            if (mismatch == 'completed-session' &&
                event['type'] == 'agent.session.turn.completed') {
              event['session_id'] = 'wrong';
            }
            if (mismatch == 'message-session' &&
                event['type'] == 'agent.session.turn.item.done') {
              event['session_id'] = 'wrong';
            }
            if (mismatch == 'message-turn' &&
                event['type'] == 'agent.session.turn.item.done') {
              event['turn_id'] = 'wrong';
            }
            return event;
          };
        final c = OpenAIClient(httpClient: t);
        final run = _run(c);
        await expectLater(
          run.finalResult(),
          throwsA(
            isA<AgentSessionRunResultException>().having(
              (e) => e.reason,
              'reason',
              AgentSessionRunResultReason.identityMismatch,
            ),
          ),
        );
        c.close();
        t.dispose();
      },
    );
  }

  test(
    'typed follow-up parses every block once, keeps first and changes no wire format',
    () async {
      final t = _Peer()
        ..events = [
          _message('a', '', blocks: ['1', '2']),
          _message('b', '3', index: 1),
        ];
      final c = OpenAIClient(httpClient: t);
      var parses = 0;
      final binding = _binding((text) {
        parses++;
        return int.parse(text);
      });
      final raw = _run(c);
      final typed = raw.withOutput(binding);
      expect(raw.withOutput(binding), same(typed));
      final first = typed.finalResult();
      expect(typed.finalResult(), same(first));
      final result = await first;
      expect(result.parsed, 1);
      expect(parses, 3);
      expect(result.outputText, '123');
      expect(result.sessionId, 'session');
      expect(
        t.wires.every((wire) => !jsonEncode(wire).contains('json_schema')),
        true,
      );
      expect(t.requests.where((r) => r.method == 'POST').length, 1);
      await typed.close();
      c.close();
      t.dispose();
    },
  );

  for (final kind in ['missing', 'later-invalid']) {
    test(
      'typed $kind output caches private parse failure and preserves successful raw result',
      () async {
        final t = _Peer()
          ..events = kind == 'missing'
              ? []
              : [
                  _message('a', '1'),
                  _message('b', 'PRIVATE-invalid', index: 1),
                ];
        final c = OpenAIClient(httpClient: t);
        var parses = 0;
        final typed = _run(c).withOutput(
          _binding((text) {
            parses++;
            return int.parse(text);
          }),
        );
        final first = typed.finalResult();
        AgentSessionOutputParseException? error;
        try {
          await first;
        } on AgentSessionOutputParseException catch (e) {
          error = e;
        }
        expect(error, isNotNull);
        expect(error!.result.turn.status.value, 'completed');
        expect(error.toString(), isNot(contains('PRIVATE')));
        expect(typed.finalResult(), same(first));
        await expectLater(first, throwsA(same(error)));
        expect(parses, kind == 'missing' ? 0 : 2);
        c.close();
        t.dispose();
      },
    );
  }

  test(
    'typed streamed creation binds canonical agent.text format, preserves verbosity and proxy cursor',
    () async {
      final t = _Peer()
        ..creation = true
        ..events = [_message('answer', '4')];
      final c = OpenAIClient(httpClient: t);
      final typed = c.agents.sessions
          .createRun(
            _request(text: AgentTextConfig(verbosity: AgentVerbosityParam.low)),
          )
          .withOutput(_binding());
      expect(typed.observedSessionId, null);
      expect(() => typed.sessionId, throwsStateError);
      expect(await typed.nextEvent(), isA<AgentSessionCreatedEvent>());
      final result = await typed.finalResult();
      expect(result.parsed, 4);
      final agent = t.wires.first['agent']! as Map;
      expect((agent['text']! as Map)['format'], {
        'type': 'json_schema',
        'schema': {'type': 'integer'},
      });
      expect((agent['text']! as Map)['verbosity'], 'low');
      expect(jsonEncode(t.wires), isNot(contains('parse')));
      expect(t.inputs, 0);
      expect(t.requests.length, 1);
      c.close();
      t.dispose();
    },
  );

  for (final text in [
    AgentTextConfig(format: const AgentTextFormat.text()),
    AgentTextConfig(clearFormat: true),
    AgentTextConfig(
      format: AgentJsonSchemaFormat(schema: const {'type': 'string'}),
    ),
  ]) {
    test('conflicting creation format rejects before HTTP ($text)', () {
      final t = _Peer();
      final c = OpenAIClient(httpClient: t);
      final run = c.agents.sessions.createRun(_request(text: text));
      expect(() => run.withOutput(_binding()), throwsFormatException);
      expect(t.requests, isEmpty);
      c.close();
      t.dispose();
    });
  }

  test(
    'conflicting binding and late output binding reject without changing captured creation',
    () async {
      final t = _Peer()..events = [_message('a', '1')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c)..withOutput(_binding());
      expect(() => run.withOutput(_binding()), throwsStateError);
      await run.start();
      expect(() => run.withOutput(_binding()), throwsStateError);
      expect((await run.finalResult()).outputText, '1');
      c.close();
      t.dispose();
    },
  );
  test(
    'registered dispatch and result collection share one checkpoint/cursor',
    () async {
      final t = _Peer()
        ..autoTerminal = false
        ..events = [
          {
            'type': 'agent.session.turn.item.added',
            'event_id': 'call-event',
            'session_id': 'session',
            'turn_id': 'root',
            'output_index': 0,
            'item': {
              'type': 'function_call',
              'id': 'call-item',
              'name': 'local',
              'arguments': <String, dynamic>{},
              'status': 'completed',
              'turn_id': 'root',
              'call_id': 'call',
            },
          },
          _state(
            'requires_action',
            actions: [
              {
                'type': 'function_call',
                'turn_id': 'root',
                'call_id': 'call',
                'name': 'local',
                'arguments': <String, dynamic>{},
              },
            ],
          ),
        ];
      final c = OpenAIClient(httpClient: t);
      var invoked = 0;
      final run = c.agents.sessions
          .stream(
            'session',
            input: AgentSessionInitialInput.text('go'),
            toolHandlers: {
              'local': (_) {
                invoked++;
                return null;
              },
            },
          )
          .withResultCollection();
      await run.nextEvent();
      await run.nextEvent();
      expect(invoked, 0);
      final result = await run.finalResult();
      expect(result.outputText, 'after-dispatch');
      expect(invoked, 1);
      expect(t.toolResults, 1);
      expect(t.inputs, 1);
      c.close();
      t.dispose();
    },
  );

  test(
    'result delivery failure remains observation error after a queued completed boundary',
    () async {
      final t = _Peer()
        ..autoTerminal = false
        ..toolStatus = 503
        ..events = [
          {
            'type': 'agent.session.turn.item.added',
            'event_id': 'call-event',
            'session_id': 'session',
            'turn_id': 'root',
            'output_index': 0,
            'item': {
              'type': 'function_call',
              'id': 'call-item',
              'name': 'local',
              'arguments': <String, dynamic>{},
              'status': 'completed',
              'turn_id': 'root',
              'call_id': 'call',
            },
          },
        ];
      final c = OpenAIClient(httpClient: t);
      final run = c.agents.sessions.stream(
        'session',
        input: AgentSessionInitialInput.text('go'),
        toolHandlers: {'local': (_) => null},
      );
      await expectLater(
        run.finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>()
              .having(
                (e) => e.reason,
                'reason',
                AgentSessionRunResultReason.observationFailed,
              )
              .having((e) => e.cause, 'cause', isA<StreamException>()),
        ),
      );
      expect(t.toolResults, 1);
      c.close();
      t.dispose();
    },
  );

  test(
    'stream break preserves partial error; it cannot be continued as a second observer',
    () async {
      final t = _Peer()..autoTerminal = false;
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.events.take(1).drain<void>();
      await expectLater(
        run.finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>().having(
            (e) => e.reason,
            'reason',
            AgentSessionRunResultReason.observationFailed,
          ),
        ),
      );
      expect(t.inputs, 1);
      expect(t.requests.length, 3);
      c.close();
      t.dispose();
    },
  );

  test(
    'premature EOF exposes incomplete observation, preserving completed partial messages',
    () async {
      final t = _Peer()
        ..autoTerminal = false
        ..events = [_message('partial', 'partial')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.nextEvent();
      await run.nextEvent();
      unawaited(t.body.close());
      await expectLater(
        run.finalResult(),
        throwsA(
          isA<AgentSessionRunResultException>()
              .having(
                (e) => e.reason,
                'reason',
                AgentSessionRunResultReason.observationFailed,
              )
              .having((e) => e.messages.length, 'messages', 1),
        ),
      );
      c.close();
      t.dispose();
    },
  );

  test(
    'canonical nullable outer message turn accepted when payload matches selected root',
    () async {
      final t = _Peer()
        ..events = [_message('answer', 'answer')..['turn_id'] = null];
      final c = OpenAIClient(httpClient: t);
      expect((await _run(c).finalResult()).outputText, 'answer');
      c.close();
      t.dispose();
    },
  );

  test(
    'parser returned arbitrary application value is reused without claiming ownership',
    () async {
      final t = _Peer()..events = [_message('answer', '{}')];
      final c = OpenAIClient(httpClient: t);
      final value = <String, Object?>{'mutable': true};
      final typed = _run(c).withOutput(
        AgentSessionOutputBinding(
          format: AgentJsonSchemaFormat(schema: const {'type': 'object'}),
          parse: (_) => value,
        ),
      );
      final result = await typed.finalResult();
      expect(result.parsed, same(value));
      value['changed'] = true;
      expect((await typed.finalResult()).parsed, same(value));
      expect(result.messages.single.content.single.text, '{}');
      c.close();
      t.dispose();
    },
  );
  test(
    'accepted manual result drains already buffered clearing state on same cursor',
    () async {
      final action = {
        'type': 'function_call',
        'turn_id': 'root',
        'call_id': 'manual',
        'name': 'manual',
        'arguments': <String, Object?>{},
      };
      final t = _Peer()
        ..autoTerminal = false
        ..events = [
          _state('requires_action', actions: [action]),
        ];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.nextEvent();
      expect(await run.nextEvent(), isA<AgentSessionRequiresActionEvent>());
      await c.agents.sessions.events.create(
        'session',
        CreateAgentSessionEventsRequest(
          events: [
            AgentSessionInput.toolResult(
              callId: 'manual',
              turnId: 'root',
              success: true,
              output: AgentSessionFunctionOutput.text('done'),
            ),
          ],
        ),
      );
      final result = await run.finalResult();
      expect(result.outputText, 'after-dispatch');
      expect(t.toolResults, 1);
      expect(t.inputs, 1);
      c.close();
      t.dispose();
    },
  );

  test(
    'early Stream break at completed idle preserves completed cached result',
    () async {
      final t = _Peer()..events = [_message('final', 'done')];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await for (final event in run.events) {
        if (event is AgentSessionIdleEvent) break;
      }
      final first = run.finalResult();
      expect((await first).outputText, 'done');
      expect(run.finalResult(), same(first));
      expect(t.inputs, 1);
      c.close();
      t.dispose();
    },
  );
  test(
    'unresolved action with unrelated queued and ongoing noise still fails promptly',
    () async {
      final t = _Peer()
        ..autoTerminal = false
        ..events = [
          _state(
            'requires_action',
            actions: [
              {'type': 'future_action'},
            ],
          ),
          for (var i = 0; i < 20; i++)
            {'type': 'future.noise', 'event_id': 'noise-$i'},
        ];
      final c = OpenAIClient(httpClient: t);
      final run = _run(c).withResultCollection();
      await run.nextEvent();
      await run.nextEvent();
      var index = 20;
      final noise = Timer.periodic(const Duration(milliseconds: 1), (_) {
        if (!t.canceled) {
          t.emit({'type': 'future.noise', 'event_id': 'noise-${index++}'});
        }
      });
      try {
        await expectLater(
          run.finalResult().timeout(const Duration(seconds: 2)),
          throwsA(
            isA<AgentSessionRunResultException>().having(
              (e) => e.reason,
              'reason',
              AgentSessionRunResultReason.requiresAction,
            ),
          ),
        );
        expect(t.canceled, true);
        expect(t.inputs, 1);
      } finally {
        noise.cancel();
        await run.close();
        c.close();
        t.dispose();
      }
    },
  );
  test(
    'forwarded child item with coordinator outer turn is excluded before root identity checks',
    () async {
      final child = _message('child', 'PRIVATE-child', turn: 'child')
        ..['turn_id'] = 'root';
      final t = _Peer()..events = [child, _message('answer', 'answer')];
      final c = OpenAIClient(httpClient: t);
      final result = await _run(c).finalResult();
      expect(result.messages.map((m) => m.id), ['answer']);
      expect(result.outputText, 'answer');
      c.close();
      t.dispose();
    },
  );
  test(
    'equal output indices preserve first-arrival order deterministically',
    () async {
      final t = _Peer()
        ..events = [
          for (var i = 0; i < 40; i++) _message('message-$i', '$i', index: 1),
        ];
      final c = OpenAIClient(httpClient: t);
      final result = await _run(c).finalResult();
      expect(result.messages.map((message) => message.id), [
        for (var i = 0; i < 40; i++) 'message-$i',
      ]);
      c.close();
      t.dispose();
    },
  );
}

final class _Peer extends http.BaseClient {
  final body = StreamController<List<int>>();
  final requests = <http.BaseRequest>[];
  final wires = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> events = [];
  bool autoTerminal = true;
  bool emitRoot = true;
  bool creation = false;
  bool canceled = false;
  String terminal = 'completed';
  int inputs = 0;
  int toolResults = 0;
  int toolStatus = 202;
  Map<String, dynamic> Function(Map<String, dynamic>)? transform;
  void emit(Map<String, dynamic> event) {
    final value = transform?.call(event) ?? event;
    body.add(utf8.encode('data: ${jsonEncode(value)}\n\n'));
  }

  void finish() {
    emit(_turn(terminal));
    emit(_state('idle'));
  }

  void initial() {
    if (emitRoot) emit(_turn('created'));
    events.forEach(emit);
    if (autoTerminal) finish();
  }

  http.StreamedResponse observation(int code) {
    body.onCancel = () => canceled = true;
    return http.StreamedResponse(
      body.stream,
      code,
      headers: {'content-type': 'text/event-stream'},
    );
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
    wires.add(wire);
    if (!request.url.path.endsWith('/events')) {
      emit({
        'type': 'agent.session.created',
        'event_id': 'created',
        'session': _session(),
      });
      initial();
      return observation(201);
    }
    if (((wire['events']! as List).single as Map)['type'] ==
        'agent.session.input.tool_result') {
      toolResults++;
      emit(_state('in_progress'));
      emit(_message('final', 'after-dispatch'));
      finish();
      if (toolStatus != 202) {
        return http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'error': {
                  'code': 'unavailable',
                  'message': 'PRIVATE-result',
                  'type': 'server_error',
                },
              }),
            ),
          ),
          toolStatus,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.StreamedResponse(const Stream.empty(), 202);
    }
    inputs++;
    initial();
    return http.StreamedResponse(const Stream.empty(), 202);
  }

  void dispose() {
    unawaited(body.close());
  }
}
