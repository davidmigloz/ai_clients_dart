import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  group('recovery close admission', () {
    for (final code in [1001, 1005, 1006, 1011, 1012, 1013, 1015]) {
      test('recoverable actual close $code reopens once', () async {
        var hooks = 0;
        var dials = 0;
        final successor = _Socket();
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (context) {
              hooks++;
              expect(context.closeCode, code);
              return const ResponsesReconnectDecision.continueWith();
            },
          ),
          reconnect: (_) async {
            dials++;
            return successor;
          },
        );
        addTearDown(harness.close);
        harness.initial.peerClose(code, 'private reason');
        await _tick();
        expect(hooks, 1);
        expect(dials, 1);
        expect(harness.connection.isClosed, isFalse);
        expect(harness.recovery.isRecovering, isFalse);
        expect(
          harness.lifecycle.whereType<ResponsesRecoveryReconnected>(),
          hasLength(1),
        );
        successor.emit({'type': 'future.response.event', 'stream_id': 'lane'});
        await _tick();
        expect(harness.messages.single.streamId, 'lane');
      });
    }

    for (final code in [
      1000,
      1002,
      1003,
      1007,
      1008,
      1009,
      1010,
      1014,
      4000,
      5555,
    ]) {
      test(
        'nonrecoverable actual close $code never prepares or dials',
        () async {
          var hooks = 0;
          var dials = 0;
          final harness = _Harness(
            options: ResponsesReconnectOptions(
              onReconnecting: (_) {
                hooks++;
                return const ResponsesReconnectDecision.continueWith();
              },
            ),
            reconnect: (_) async {
              dials++;
              return _Socket();
            },
          );
          addTearDown(harness.close);
          harness.initial.peerClose(code, 'private reason');
          final report = await harness.recovery.done;
          await harness.connection.done;
          expect(hooks, 0);
          expect(dials, 0);
          expect(report.code, code);
          expect(report.reason, 'private reason');
          expect(report.cause, 'nonrecoverable_close');
          expect(harness.connection.closeCode, code);
          expect(report.toString(), isNot(contains('private reason')));
        },
      );
    }

    test('zero attempts disables admission despite a required hook', () async {
      var hooks = 0;
      var dials = 0;
      final harness = _Harness(
        options: ResponsesReconnectOptions(
          onReconnecting: (_) {
            hooks++;
            return const ResponsesReconnectDecision.continueWith();
          },
          maxAttempts: 0,
        ),
        reconnect: (_) async {
          dials++;
          return _Socket();
        },
      );
      addTearDown(harness.close);
      harness.initial.peerClose(1006);
      expect((await harness.recovery.done).cause, 'reconnect_disabled');
      expect(hooks, 0);
      expect(dials, 0);
    });

    for (final withoutNotification in [false, true]) {
      test(
        'missing close code normalizes to1006 notificationAbsent=$withoutNotification',
        () async {
          ResponsesReconnectContext? prepared;
          final harness = _Harness(
            options: ResponsesReconnectOptions(
              onReconnecting: (context) {
                prepared = context;
                return const ResponsesReconnectDecision.abort();
              },
            ),
          );
          addTearDown(harness.close);
          if (withoutNotification) {
            harness.initial.endWithoutClose();
          } else {
            harness.initial.peerClose(null);
          }
          await harness.recovery.done;
          expect(prepared?.closeCode, 1006);
        },
      );
    }

    test(
      'receive error remains visible but does not preempt policy close',
      () async {
        var dials = 0;
        final harness = _Harness(
          reconnect: (_) async {
            dials++;
            return _Socket();
          },
        );
        addTearDown(harness.close);
        harness.initial.failReceive(StateError('private credential'));
        await _tick();
        expect(harness.connection.isClosed, isFalse);
        expect(dials, 0);
        expect(harness.errors, isEmpty);
        final notice =
            harness.lifecycle.single as ResponsesRecoveryTransportError;
        expect(notice.operation, 'receive');
        expect(notice.toString(), isNot(contains('private credential')));
        harness.initial.peerClose(1008);
        expect((await harness.recovery.done).code, 1008);
        expect(dials, 0);
      },
    );
  });

  group('replacement generation safety', () {
    test(
      'retired generation data/close cannot affect a replacement socket',
      () async {
        var dials = 0;
        final successor = _Socket();
        final harness = _Harness(
          reconnect: (_) async {
            dials++;
            return successor;
          },
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        await _tick();
        harness.initial.emitStale(
          ws.TextDataReceived('{"type":"future.stale"}'),
        );
        harness.initial.emitStale(ws.CloseReceived(1008, 'stale close'));
        successor.emit({'type': 'future.current'});
        await _tick();
        expect(dials, 1);
        expect(harness.connection.isClosed, isFalse);
        expect(harness.messages.single.type, 'future.current');
        expect(harness.recovery.currentAttempt?.closeCode, 1006);
      },
    );

    for (final code in [1006, 1008]) {
      test(
        'synchronous candidate close $code obeys policy without parallel retry loops',
        () async {
          var dials = 0;
          final candidate = _Socket();
          candidate.onListen = () => candidate.peerClose(code);
          final successor = _Socket();
          final harness = _Harness(
            reconnect: (_) async {
              dials++;
              return dials == 1 ? candidate : successor;
            },
          );
          addTearDown(harness.close);
          harness.initial.peerClose(1006);
          harness.facade.sendText('never replay old frames');
          if (code == 1008) {
            final report = await harness.recovery.done;
            expect(report.code, 1008);
            expect(
              report.unsentMessages.single.text,
              'never replay old frames',
            );
            expect(dials, 1);
            expect(successor.writes, isEmpty);
          } else {
            await _tick();
            expect(dials, 2);
            expect(harness.recovery.isRecovering, isFalse);
            expect(harness.recovery.currentAttempt?.attempt, 2);
            expect(successor.writes, ['never replay old frames']);
            expect(
              harness.lifecycle
                  .whereType<ResponsesRecoveryReconnected>()
                  .single
                  .attempt,
              2,
            );
          }
        },
      );
    }
  });

  group('preparation, backoff and cancellation', () {
    for (final random in [0.0, 0.5, 1.0]) {
      test(
        'five attempts exponential cap with jitter endpoint $random',
        () async {
          final contexts = <ResponsesReconnectContext>[];
          final delays = <Duration>[];
          var dials = 0;
          final harness = _Harness(
            options: ResponsesReconnectOptions(
              onReconnecting: (context) {
                contexts.add(context);
                return const ResponsesReconnectDecision.continueWith();
              },
            ),
            random: () => random,
            delay: (delay) {
              delays.add(delay);
              return Future.value();
            },
            reconnect: (_) {
              dials++;
              return Future.error(StateError('private handshake'));
            },
          );
          addTearDown(harness.close);
          harness.initial.peerClose(1013);
          final report = await harness.recovery.done;
          expect(dials, 5);
          expect(contexts.map((e) => e.attempt), [1, 2, 3, 4, 5]);
          expect(contexts.every((e) => e.maxAttempts == 5), isTrue);
          expect(delays.map((e) => e.inMilliseconds), switch (random) {
            0 => [375, 750, 1500, 3000, 6000],
            0.5 => [438, 875, 1750, 3500, 7000],
            _ => [500, 1000, 2000, 4000, 8000],
          });
          expect(contexts.map((e) => e.delay), delays);
          expect(report.cause, 'exhausted');
          expect(report.code, 1013);
          expect(harness.recovery.currentAttempt?.attempt, 5);
          await _tick();
          expect(
            harness.lifecycle.whereType<ResponsesRecoveryTransportError>(),
            hasLength(5),
          );
          expect(
            harness.lifecycle.any(
              (e) => e.toString().contains('private handshake'),
            ),
            isFalse,
          );
        },
      );
    }

    test('cap below initial applies from first attempt', () async {
      final contexts = <ResponsesReconnectContext>[];
      final harness = _Harness(
        options: ResponsesReconnectOptions(
          onReconnecting: (context) {
            contexts.add(context);
            return const ResponsesReconnectDecision.continueWith();
          },
          initialDelay: const Duration(seconds: 20),
          maxDelay: const Duration(milliseconds: 100),
          maxAttempts: 2,
        ),
        random: () => 1,
        reconnect: (_) async => throw StateError('fail'),
      );
      addTearDown(harness.close);
      harness.initial.peerClose(1006);
      await harness.recovery.done;
      expect(contexts.map((e) => e.delay.inMilliseconds), [100, 100]);
    });

    test(
      'zero-delay recovery supports more than1024 attempts without NaN',
      () async {
        var dials = 0;
        final harness = _Harness(
          options: const ResponsesReconnectOptions(
            onReconnecting: _continue,
            maxAttempts: 1100,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
          ),
          reconnect: (_) {
            dials++;
            return Future.error(StateError('dial failed'));
          },
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        expect((await harness.recovery.done).cause, 'exhausted');
        expect(dials, 1100);
        expect(harness.recovery.currentAttempt?.delay, Duration.zero);
      },
    );

    test(
      'direct preparation snapshots maps before scheduled caller mutation',
      () async {
        final query = {'session': 'before'};
        final headers = {'X-State': 'before'};
        ResponsesReconnectDecision? captured;
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (_) {
              scheduleMicrotask(() {
                query['session'] = 'after';
                headers['X-State'] = 'after';
              });
              return ResponsesReconnectDecision.continueWith(
                queryParameters: query,
                headers: headers,
              );
            },
          ),
          reconnect: (decision) async {
            captured = decision;
            return _Socket();
          },
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        await _tick();
        expect(query['session'], 'after');
        expect(headers['X-State'], 'after');
        expect(captured?.queryParameters, {'session': 'before'});
        expect(captured?.headers, {'X-State': 'before'});
      },
    );

    test(
      'async preparation precedes delay and dial, snapshots overrides before delay',
      () async {
        final preparation = Completer<ResponsesReconnectDecision>();
        final clock = _Clock();
        final query = {'session': 'before'};
        final headers = {'X-State': 'before'};
        ResponsesReconnectDecision? dialDecision;
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (_) => preparation.future,
          ),
          delay: clock.wait,
          reconnect: (decision) async {
            dialDecision = decision;
            return _Socket();
          },
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1012);
        harness.facade.sendText('newly unsent');
        await _tick();
        expect(clock.delays, isEmpty);
        expect(dialDecision, isNull);
        preparation.complete(
          ResponsesReconnectDecision.continueWith(
            queryParameters: query,
            headers: headers,
          ),
        );
        await _tick();
        query['session'] = 'after';
        headers['X-State'] = 'after';
        expect(clock.delays, hasLength(1));
        expect(dialDecision, isNull);
        clock.release();
        await _tick();
        expect(dialDecision?.queryParameters, {'session': 'before'});
        expect(dialDecision?.headers, {'X-State': 'before'});
        expect(() => dialDecision!.headers!.clear(), throwsUnsupportedError);
        expect(harness.recovery.queuedMessages, 0);
      },
    );

    for (final throwsHook in [false, true]) {
      test(
        'hook abort/throw is terminal throws=$throwsHook and reports unsent',
        () async {
          final gate = Completer<ResponsesReconnectDecision>();
          var dials = 0;
          final harness = _Harness(
            options: ResponsesReconnectOptions(
              onReconnecting: (_) => gate.future,
            ),
            reconnect: (_) async {
              dials++;
              return _Socket();
            },
          );
          addTearDown(harness.close);
          harness.initial.peerClose(1006);
          harness.facade.sendText('never attempted');
          if (throwsHook) {
            gate.completeError(StateError('private secret'));
          } else {
            gate.complete(const ResponsesReconnectDecision.abort());
          }
          final report = await harness.recovery.done;
          expect(dials, 0);
          expect(
            report.cause,
            throwsHook ? 'preparation_failed' : 'preparation_aborted',
          );
          expect(report.unsentMessages.single.text, 'never attempted');
          expect(harness.initial.writes, isEmpty);
          expect(report.toString(), isNot(contains('private secret')));
        },
      );
    }

    for (final stage in ['preparation', 'delay', 'handshake']) {
      test(
        'explicit close during $stage is prompt; late work is consumed',
        () async {
          final preparation = Completer<ResponsesReconnectDecision>();
          final delay = Completer<void>();
          final opening = Completer<ws.WebSocket>();
          var dials = 0;
          var hooks = 0;
          final harness = _Harness(
            options: ResponsesReconnectOptions(
              onReconnecting: (_) {
                hooks++;
                return stage == 'preparation'
                    ? preparation.future
                    : const ResponsesReconnectDecision.continueWith();
              },
            ),
            delay: (_) => stage == 'delay' ? delay.future : Future.value(),
            reconnect: (_) {
              dials++;
              return opening.future;
            },
          );
          addTearDown(harness.close);
          harness.initial.peerClose(1006);
          harness.facade.sendText('queued before close');
          await _tick();
          expect(hooks, 1);
          expect(dials, stage == 'handshake' ? 1 : 0);
          await harness.connection
              .close(3001, 'caller close')
              .timeout(const Duration(seconds: 1));
          await harness.connection.done;
          final report = await harness.recovery.done;
          expect(report.cause, 'explicit_close');
          expect(report.unsentMessages.single.text, 'queued before close');
          if (stage == 'preparation') {
            preparation.completeError(StateError('private late hook'));
          }
          if (stage == 'delay') {
            delay.completeError(StateError('private late wait'));
          }
          final late = _Socket();
          opening.complete(late);
          await _tick();
          expect(late.closeCalls, stage == 'handshake' ? 1 : 0);
          expect(dials, stage == 'handshake' ? 1 : 0);
          expect(harness.recovery.closed, same(report));
        },
      );
    }

    test('late failed handshake after close is consumed', () async {
      final opening = Completer<ws.WebSocket>();
      final harness = _Harness(reconnect: (_) => opening.future);
      addTearDown(harness.close);
      harness.initial.peerClose(1006);
      await _tick();
      await harness.connection.close();
      opening.completeError(StateError('private late handshake'));
      await _tick();
      expect(harness.recovery.closed?.cause, 'explicit_close');
    });

    test('late handshake success close failure is consumed safely', () async {
      final opening = Completer<ws.WebSocket>();
      final harness = _Harness(reconnect: (_) => opening.future);
      addTearDown(harness.close);
      harness.initial.peerClose(1006);
      await _tick();
      await harness.connection.close();
      final late = _Socket()..closeFailure = StateError('private close');
      opening.complete(late);
      await _tick();
      expect(late.closeCalls, 1);
      expect(harness.recovery.isClosed, isTrue);
    });

    test(
      'explicit connected close is idempotent and never reconnects',
      () async {
        var dials = 0;
        final harness = _Harness(
          reconnect: (_) async {
            dials++;
            return _Socket();
          },
        );
        addTearDown(harness.close);
        final a = harness.connection.close(3005, 'done');
        final b = harness.connection.close(3005, 'done');
        expect(a, same(b));
        await a;
        await _tick();
        expect(harness.initial.closeCalls, 1);
        expect(harness.initial.requestedCode, 3005);
        expect(harness.initial.requestedReason, 'done');
        expect(dials, 0);
        expect(harness.recovery.closed?.cause, 'explicit_close');
      },
    );

    test(
      'close failure still completes connection and lifecycle teardown',
      () async {
        final harness = _Harness();
        harness.initial.closeFailure = StateError('private secret');
        await expectLater(
          harness.connection.close(),
          throwsA(isA<ResponsesTransportException>()),
        );
        await harness.connection.done;
        expect((await harness.recovery.done).cause, 'explicit_close');
        expect(harness.connection.isClosed, isTrue);
        await harness.cancelListeners();
      },
    );

    test(
      'absent or paused lifecycle listener never delays final report',
      () async {
        final facade = ResponsesRecoveringWebSocket(
          _Socket(),
          options: const ResponsesReconnectOptions(onReconnecting: _continue),
          reconnect: (_) async => _Socket(),
          delay: (_) async {},
        );
        final connection = ResponsesConnection(
          facade,
          recovery: facade.recovery,
        );
        final paused = facade.recovery.events.listen((_) {})..pause();
        await connection.close().timeout(const Duration(seconds: 1));
        await connection.done;
        final report = await facade.recovery.done;
        expect(facade.recovery.closed, same(report));
        expect(facade.recovery.lastEvent, same(report));
        await paused.cancel();
      },
    );

    test(
      'cancelling one lifecycle listener does not cancel recovery',
      () async {
        final clock = _Clock();
        final harness = _Harness(delay: clock.wait);
        addTearDown(harness.close);
        final local = harness.recovery.events.listen((_) {});
        harness.initial.peerClose(1006);
        await _tick();
        await local.cancel();
        expect(harness.recovery.isRecovering, isTrue);
        clock.release();
        await _tick();
        expect(
          harness.lifecycle.whereType<ResponsesRecoveryReconnected>(),
          hasLength(1),
        );
        expect(harness.connection.isClosed, isFalse);
      },
    );
  });

  group('strict never-attempted queue ownership', () {
    test(
      'strict default 1MiB boundary rejects oversized first frame',
      () async {
        final gate = Completer<ResponsesReconnectDecision>();
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (_) => gate.future,
          ),
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        expect(
          () => harness.facade.sendText('a' * 1048577),
          throwsA(isA<ResponsesSendQueueOverflowException>()),
        );
        expect(harness.recovery.queuedBytes, 0);
        harness.facade.sendText('a' * 1048576);
        expect(harness.recovery.queuedBytes, 1048576);
        expect(
          () => harness.facade.sendText('b'),
          throwsA(isA<ResponsesSendQueueOverflowException>()),
        );
        expect(harness.recovery.queuedMessages, 1);
        expect(harness.connection.isClosed, isFalse);
        gate.complete(const ResponsesReconnectDecision.abort());
        final report = await harness.recovery.done;
        expect(report.unsentMessages.single.byteLength, 1048576);
      },
    );

    test(
      'multibyte UTF8 accounting and overflow preserve prior queue',
      () async {
        final gate = Completer<ResponsesReconnectDecision>();
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (_) => gate.future,
            maxQueueBytes: 6,
          ),
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        harness.facade.sendText('é🙂');
        expect(harness.recovery.queuedBytes, 6);
        expect(
          () => harness.facade.sendText('a'),
          throwsA(isA<ResponsesSendQueueOverflowException>()),
        );
        await _tick();
        final notice = harness.lifecycle
            .whereType<ResponsesRecoveryQueueOverflow>()
            .single;
        expect(notice.frameBytes, 1);
        expect(notice.queuedBytes, 6);
        gate.complete(const ResponsesReconnectDecision.abort());
        expect((await harness.recovery.done).unsentMessages.single.text, 'é🙂');
      },
    );

    test('zero queue budget rejects only newly queued frames', () async {
      final gate = Completer<ResponsesReconnectDecision>();
      final harness = _Harness(
        options: ResponsesReconnectOptions(
          onReconnecting: (_) => gate.future,
          maxQueueBytes: 0,
        ),
      );
      addTearDown(harness.close);
      harness.facade.sendText('already attempted');
      harness.initial.peerClose(1006);
      expect(
        () => harness.facade.sendText('new'),
        throwsA(isA<ResponsesSendQueueOverflowException>()),
      );
      expect(
        () => harness.facade.sendText(''),
        throwsA(isA<ResponsesSendQueueOverflowException>()),
      );
      expect(harness.initial.writes, ['already attempted']);
      expect(harness.recovery.queuedBytes, 0);
      gate.complete(const ResponsesReconnectDecision.abort());
      expect((await harness.recovery.done).unsentMessages, isEmpty);
    });

    test(
      'public writer overflow is observable without terminating recovery',
      () async {
        final gate = Completer<ResponsesReconnectDecision>();
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (_) => gate.future,
            maxQueueBytes: 1,
          ),
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        expect(
          () => harness.connection.steer(
            previousResponseId: 'parent',
            input: const ResponsesSteerInput.text('private secret'),
          ),
          throwsA(isA<ResponsesSendQueueOverflowException>()),
        );
        expect(harness.connection.isClosed, isFalse);
        expect(harness.recovery.isRecovering, isTrue);
        expect(harness.errors, isEmpty);
        expect(harness.recovery.queuedMessages, 0);
        gate.complete(const ResponsesReconnectDecision.abort());
        await harness.recovery.done;
      },
    );

    test(
      'serialized request snapshot is immutable despite caller mutation',
      () async {
        final clock = _Clock();
        final successor = _Socket();
        final harness = _Harness(
          delay: clock.wait,
          reconnect: (_) async => successor,
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        final values = <Map<String, dynamic>>[
          {
            'type': 'function_call_output',
            'call_id': 'call',
            'output': 'before',
          },
        ];
        harness.connection.create(
          CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.fromOutputItems(values),
          ),
        );
        final bytes = harness.recovery.queuedBytes;
        values.single['output'] = 'after';
        values.add({'private': 'not sent'});
        expect(harness.recovery.queuedBytes, bytes);
        await _tick();
        clock.release();
        await _tick();
        final sent =
            jsonDecode(successor.writes.single) as Map<String, dynamic>;
        expect(sent['input'], [
          {
            'type': 'function_call_output',
            'call_id': 'call',
            'output': 'before',
          },
        ]);
        expect(utf8.encode(successor.writes.single).length, bytes);
      },
    );

    test(
      'already sent create steer inject never replay; only new frames flush FIFO',
      () async {
        final clock = _Clock();
        final successor = _Socket();
        final harness = _Harness(
          beta: true,
          delay: clock.wait,
          reconnect: (_) async => successor,
        );
        addTearDown(harness.close);
        harness.connection.create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('initial'),
          ),
        );
        harness.connection.steer(
          previousResponseId: 'parent',
          input: const ResponsesSteerInput.text('submitted steer'),
        );
        harness.facade.sendText(
          jsonEncode({
            'type': 'response.inject',
            'response_id': 'parent',
            'input': [
              {
                'type': 'function_call_output',
                'call_id': 'call_old',
                'output': 'submitted injection',
              },
            ],
          }),
        );
        harness.initial.peerClose(1006);
        harness.connection.create(
          const CreateResponseRequest(
            model: 'gpt-6-sol',
            input: ResponseInput.text('new create'),
          ),
        );
        harness.connection.steer(
          previousResponseId: 'new_parent',
          input: const ResponsesSteerInput.text('new steer'),
        );
        harness.facade.sendText(
          jsonEncode({
            'type': 'response.inject',
            'response_id': 'new_parent',
            'input': [
              {
                'type': 'function_call_output',
                'call_id': 'call_new',
                'output': 'new injection',
              },
            ],
          }),
        );
        await _tick();
        expect(harness.initial.writes, hasLength(3));
        expect(harness.recovery.queuedMessages, 3);
        clock.release();
        await _tick();
        expect(
          successor.writes.map(
            (e) => (jsonDecode(e) as Map<String, dynamic>)['type'],
          ),
          ['response.create', 'response.steer', 'response.inject'],
        );
        expect(successor.writes, hasLength(3));
        expect(
          successor.writes.any(
            (e) => e.contains('initial') || e.contains('submitted'),
          ),
          isFalse,
        );
        expect(harness.initial.writes, hasLength(3));
      },
    );

    test(
      'reentrant flush sends append FIFO; remainder stays charged until attempt',
      () async {
        final clock = _Clock();
        final successor = _Socket();
        late final _Harness harness;
        final observedBytes = <int>[];
        successor.onWrite = (text) {
          observedBytes.add(harness.recovery.queuedBytes);
          if (text == 'first') {
            harness.facade.sendText('third');
            expect(harness.recovery.queuedBytes, 11);
            expect(
              () => harness.facade.sendText('extra'),
              throwsA(isA<ResponsesSendQueueOverflowException>()),
            );
          }
        };
        harness = _Harness(
          options: const ResponsesReconnectOptions(
            onReconnecting: _continue,
            maxQueueBytes: 12,
          ),
          delay: clock.wait,
          reconnect: (_) async => successor,
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        harness.facade.sendText('first');
        harness.facade.sendText('second');
        await _tick();
        clock.release();
        await _tick();
        expect(successor.writes, ['first', 'second', 'third']);
        expect(observedBytes, [6, 5, 0]);
        expect(harness.recovery.queuedBytes, 0);
        expect(harness.recovery.isRecovering, isFalse);
      },
    );

    test(
      'fail after queued write excludes attempted frame and reports only remainder',
      () async {
        final clock = _Clock();
        final successor = _Socket();
        var dials = 0;
        late final _Harness harness;
        successor.onWrite = (text) {
          if (text == 'first') {
            harness.facade.sendText('reentrant remainder');
            throw StateError('private unknown delivery');
          }
        };
        harness = _Harness(
          delay: clock.wait,
          reconnect: (_) async {
            dials++;
            return successor;
          },
        );
        addTearDown(harness.close);
        harness.initial.peerClose(1006);
        harness.facade.sendText('first');
        harness.facade.sendText('second');
        await _tick();
        clock.release();
        final report = await harness.recovery.done;
        await harness.connection.done;
        await _tick();
        expect(successor.writes, ['first']);
        expect(report.cause, 'delivery_unknown');
        expect(report.unsentMessages.map((e) => e.text), [
          'second',
          'reentrant remainder',
        ]);
        expect(report.unsentMessages.any((e) => e.text == 'first'), isFalse);
        expect(
          harness.lifecycle
              .whereType<ResponsesRecoveryDeliveryUnknown>()
              .single
              .operation,
          'flush',
        );
        expect(
          harness.lifecycle.whereType<ResponsesRecoveryReconnected>(),
          isEmpty,
        );
        expect(dials, 1);
        expect(harness.recovery.queuedBytes, 0);
      },
    );

    test(
      'active attempted write failure is terminal unknown delivery, never retry',
      () async {
        var dials = 0;
        final harness = _Harness(
          reconnect: (_) async {
            dials++;
            return _Socket();
          },
        );
        addTearDown(harness.close);
        harness.initial.onWrite = (_) => throw StateError('private write');
        expect(
          () => harness.connection.steer(
            previousResponseId: 'parent',
            input: const ResponsesSteerInput.text('private secret'),
          ),
          throwsA(isA<ResponsesDeliveryUnknownException>()),
        );
        final report = await harness.recovery.done;
        await harness.connection.done;
        await _tick();
        expect(harness.initial.writes, hasLength(1));
        expect(report.code, isNull);
        expect(report.unsentMessages, isEmpty);
        expect(report.cause, 'delivery_unknown');
        expect(dials, 0);
        expect(
          harness.lifecycle
              .whereType<ResponsesRecoveryDeliveryUnknown>()
              .single
              .operation,
          'send',
        );
        expect(
          harness.errors.whereType<ResponsesDeliveryUnknownException>(),
          hasLength(1),
        );
        expect(harness.connection.isClosed, isTrue);
      },
    );

    test(
      'final report is frozen and observable after listener cancellation',
      () async {
        final gate = Completer<ResponsesReconnectDecision>();
        final harness = _Harness(
          options: ResponsesReconnectOptions(
            onReconnecting: (_) => gate.future,
          ),
        );
        addTearDown(harness.close);
        await harness.lifecycleSubscription.cancel();
        harness.initial.peerClose(1006);
        harness.facade.sendText('{"type":"response.steer","input":"private"}');
        await harness.connection.close();
        final report = await harness.recovery.done;
        expect(report.unsentMessages, same(harness.recovery.unsentMessages));
        expect(report.unsentMessages.single.message['input'], 'private');
        expect(report.toString(), isNot(contains('private')));
        expect(
          report.unsentMessages.single.toString(),
          isNot(contains('private')),
        );
        expect(report.unsentMessages.clear, throwsUnsupportedError);
        expect(
          () => report.unsentMessages.single.message.clear(),
          throwsUnsupportedError,
        );
      },
    );
  });
}

ResponsesReconnectDecision _continue(ResponsesReconnectContext _) =>
    const ResponsesReconnectDecision.continueWith();

Future<void> _tick() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Clock {
  final List<Duration> delays = [];
  final Queue<Completer<void>> _pending = Queue();

  Future<void> wait(Duration delay) {
    delays.add(delay);
    final completion = Completer<void>();
    _pending.add(completion);
    return completion.future;
  }

  void release() => _pending.removeFirst().complete();
}

class _Harness {
  _Harness({
    ResponsesReconnectOptions options = const ResponsesReconnectOptions(
      onReconnecting: _continue,
    ),
    Future<ws.WebSocket> Function(ResponsesReconnectDecision)? reconnect,
    Future<void> Function(Duration)? delay,
    double Function()? random,
    bool beta = false,
  }) {
    facade = ResponsesRecoveringWebSocket(
      initial,
      options: options,
      reconnect: reconnect ?? (_) async => _Socket(),
      delay: delay ?? (_) async {},
      random: random ?? () => 1,
    );
    connection = ResponsesConnection(
      facade,
      recovery: facade.recovery,
      beta: beta,
    );
    messageSubscription = connection.events.listen(
      messages.add,
      onError: errors.add,
    );
    lifecycleSubscription = recovery.events.listen(lifecycle.add);
  }

  final _Socket initial = _Socket();
  late final ResponsesRecoveringWebSocket facade;
  late final ResponsesConnection connection;
  late final StreamSubscription<ResponsesServerEvent> messageSubscription;
  late final StreamSubscription<ResponsesRecoveryEvent> lifecycleSubscription;
  final List<ResponsesServerEvent> messages = [];
  final List<Object> errors = [];
  final List<ResponsesRecoveryEvent> lifecycle = [];

  ResponsesRecovery get recovery => facade.recovery;

  Future<void> cancelListeners() async {
    await messageSubscription.cancel();
    await lifecycleSubscription.cancel();
  }

  Future<void> close() async {
    await connection.close();
    await connection.done;
    await cancelListeners();
  }
}

class _Socket implements ws.WebSocket {
  _Socket() {
    _events = StreamController(sync: true);
  }

  late final StreamController<ws.WebSocketEvent> _events;
  final List<String> writes = [];
  void Function(String)? onWrite;
  void Function()? onListen;
  void Function(ws.WebSocketEvent)? _savedOnData;
  Error? closeFailure;
  int closeCalls = 0;
  int? requestedCode;
  String? requestedReason;
  bool _closed = false;

  @override
  Stream<ws.WebSocketEvent> get events => _CapturedStream(this);
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    if (_closed) throw ws.WebSocketConnectionClosed();
    writes.add(text);
    onWrite?.call(text);
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('text fixture');

  void emit(Map<String, dynamic> event) =>
      _events.add(ws.TextDataReceived(jsonEncode(event)));
  void failReceive(Object error) => _events.addError(error);
  void emitStale(ws.WebSocketEvent event) => _savedOnData?.call(event);

  void peerClose(int? code, [String reason = '']) {
    if (_closed) return;
    _closed = true;
    _events.add(ws.CloseReceived(code, reason));
    unawaited(_events.close());
  }

  void endWithoutClose() {
    _closed = true;
    unawaited(_events.close());
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    requestedCode = code;
    requestedReason = reason;
    if (closeFailure case final error?) throw error;
    if (!_closed) peerClose(code, reason ?? '');
  }
}

class _CapturedStream extends Stream<ws.WebSocketEvent> {
  _CapturedStream(this.socket);

  final _Socket socket;

  @override
  StreamSubscription<ws.WebSocketEvent> listen(
    void Function(ws.WebSocketEvent)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    socket._savedOnData = onData;
    final subscription = socket._events.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    socket.onListen?.call();
    return subscription;
  }
}
