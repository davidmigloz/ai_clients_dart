import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

import '../fixtures/responses_websocket_events.dart';

const _saved = FunctionCallOutputItem(
  callId: 'call_saved',
  agent: AgentTag(agentName: '/root/sub'),
  output: FunctionCallOutputString('saved result'),
);

void main() {
  group('public beta injection writes', () {
    test(
      'beta handshake uses forced header on plain repeated-query Responses URL',
      () async {
        final client = OpenAIClient(
          config: const OpenAIConfig(
            baseUrl: 'https://example.invalid/proxy/v1?k=a&k=b',
            defaultHeaders: {'openai-beta': 'wrong default'},
          ),
        );
        final socket = _Socket();
        Uri? requested;
        Map<String, String>? sentHeaders;
        final connection = await client.responses.connect(
          beta: true,
          additionalHeaders: const {'OPENAI-BETA': 'wrong override'},
          connector: (uri, {headers}) async {
            requested = uri;
            sentHeaders = headers;
            return socket;
          },
        );
        addTearDown(client.close);
        addTearDown(connection.close);
        expect(requested?.scheme, 'wss');
        expect(requested?.path, '/proxy/v1/responses');
        expect(requested?.queryParametersAll['k'], ['a', 'b']);
        expect(requested?.queryParameters.containsKey('beta'), isFalse);
        expect(requested?.queryParameters.containsKey('betas'), isFalse);
        expect(sentHeaders?['openai-beta'], 'responses_multi_agent=v1');
        expect(
          sentHeaders!.keys.where((key) => key.toLowerCase() == 'openai-beta'),
          hasLength(1),
        );
        expect(connection.beta, isTrue);
        connection.inject(responseId: 'resp_parent', input: const [_saved]);
        expect(socket.frames.single, {
          'type': 'response.inject',
          'response_id': 'resp_parent',
          'input': [_saved.toJson()],
        });
      },
    );

    test(
      'typed send/convenience tear-offs keep exact three fields and item agent',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        final void Function(ResponseInjectEvent) send =
            harness.connection.sendInject;
        final void Function({
          required String responseId,
          required List<Item> input,
        })
        inject = harness.connection.inject;
        final void Function(ResponsesCreateEvent) create =
            harness.connection.send;
        final void Function(ResponsesSteerEvent) steer =
            harness.connection.sendSteer;
        create(const ResponsesCreateEvent(request: _request));
        steer(
          const ResponsesSteerEvent(
            previousResponseId: 'resp_parent',
            input: ResponsesSteerInput.text('correction'),
          ),
        );
        send(
          const ResponseInjectEvent(responseId: 'resp_parent', input: [_saved]),
        );
        inject(responseId: 'resp_parent', input: const [_saved]);
        expect(harness.socket.frames.map((e) => e['type']), [
          'response.create',
          'response.steer',
          'response.inject',
          'response.inject',
        ]);
        for (final frame in harness.socket.frames.skip(2)) {
          expect(frame.keys.toSet(), {'type', 'response_id', 'input'});
          expect(frame['input'], [_saved.toJson()]);
          expect(jsonEncode(frame), isNot(contains('stream_id')));
        }
      },
    );

    for (final convenience in [false, true]) {
      test(
        'GA gate precedes serialization/writes convenience=$convenience',
        () async {
          final harness = await _Harness.open(beta: false);
          addTearDown(harness.close);
          final bad = _BadOutput();
          expect(() {
            if (convenience) {
              harness.connection.inject(responseId: 'parent', input: [bad]);
            } else {
              harness.connection.sendInject(
                ResponseInjectEvent(responseId: 'parent', input: [bad]),
              );
            }
          }, throwsArgumentError);
          expect(bad.serializations, 0);
          expect(harness.socket.writes, isEmpty);
          expect(harness.connection.isClosed, isFalse);
        },
      );
    }

    test(
      'both methods reject eagerly after close before serialization',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        await harness.connection.close();
        final bad = _BadOutput();
        expect(
          () => harness.connection.inject(responseId: 'parent', input: [bad]),
          throwsStateError,
        );
        expect(
          () => harness.connection.sendInject(
            ResponseInjectEvent(responseId: 'parent', input: [bad]),
          ),
          throwsStateError,
        );
        expect(bad.serializations, 0);
        expect(harness.socket.writes, isEmpty);
      },
    );

    test(
      'unserializable nested input fails contextually without a write',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        final bad = _BadOutput();
        expect(
          () => harness.connection.inject(
            responseId: 'private parent',
            input: [bad],
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.toString(),
              'redaction',
              isNot(contains('private')),
            ),
          ),
        );
        expect(bad.serializations, 1);
        expect(harness.socket.writes, isEmpty);
        expect(harness.connection.isClosed, isFalse);
      },
    );

    test(
      'custom event JSON encoding fails with redacted invalid_inject',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        expect(
          () => harness.connection.sendInject(const _BadEvent()),
          throwsA(
            isA<ResponsesProtocolException>()
                .having((e) => e.kind, 'kind', 'invalid_inject')
                .having(
                  (e) => e.toString(),
                  'redaction',
                  isNot(contains('private')),
                ),
          ),
        );
        expect(harness.socket.writes, isEmpty);
        expect(harness.connection.isClosed, isFalse);
      },
    );

    test(
      'empty/broad input remains available; canonical16384 cap rejects before write',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        harness.connection.inject(responseId: 'parent', input: const []);
        harness.connection.inject(
          responseId: 'parent',
          input: const [
            MessageItem(
              role: MessageRole.user,
              content: [InputContent.text('schema branch')],
            ),
          ],
        );
        expect(harness.socket.frames.first['input'], isEmpty);
        expect(
          ((harness.socket.frames.last['input'] as List<dynamic>).single
              as Map<String, dynamic>)['type'],
          'message',
        );
        expect(
          () => harness.connection.inject(
            responseId: 'parent',
            input: List<Item>.filled(16385, _saved),
          ),
          throwsFormatException,
        );
        expect(harness.socket.writes, hasLength(2));
      },
    );
  });

  group('public injection acknowledgements', () {
    for (final lane in <String?>[null, 'workers']) {
      for (final failed in [false, true]) {
        test(
          'typed acknowledgment complete raw roundtrip failed=$failed lane=$lane',
          () async {
            final harness = await _Harness.open();
            addTearDown(harness.close);
            final frame = failed
                ? _failed(
                    'resp_parent',
                    [_saved.toJson()],
                    lane: lane,
                    code: 'future_injection_code',
                  )
                : _accepted('resp_parent', lane: lane);
            frame['future'] = {
              'private': [true, null],
            };
            frame['agent'] = {
              'agent_name': '/future/metadata',
              'future_agent': 1,
            };
            harness.socket.emit(frame);
            await _tick();
            final event = harness.messages.single;
            expect(event.streamId, lane);
            expect(event.rawJson['agent'], frame['agent']);
            expect(event.toJson(), frame);
            if (failed) {
              final ack = event as ResponseInjectFailedEvent;
              expect(ack.responseId, 'resp_parent');
              expect(ack.sequenceNumber, 8);
              expect(ack.error.code, ResponseInjectErrorCode.unknown);
              expect(ack.error.rawCode, 'future_injection_code');
              expect(ack.input, [_saved.toJson()]);
              expect(ack.toString(), isNot(contains('private')));
            } else {
              final ack = event as ResponseInjectCreatedEvent;
              expect(ack.responseId, 'resp_parent');
              expect(ack.sequenceNumber, 7);
            }
            expect(harness.socket.writes, isEmpty);
            expect(harness.connection.isClosed, isFalse);
          },
        );
      }
    }

    for (final type in ['response.inject.created', 'response.inject.failed']) {
      test(
        'malformed known acknowledgment $type is identifiable and no completion is fabricated',
        () async {
          final harness = await _Harness.open();
          addTearDown(harness.close);
          harness.socket.emit({'type': type, 'response_id': 'resp_parent'});
          await _tick();
          expect(
            harness.errors.single,
            isA<ResponsesProtocolException>().having(
              (e) => e.kind,
              'kind',
              'invalid_event',
            ),
          );
          expect(harness.messages, isEmpty);
          expect(harness.connection.isClosed, isFalse);
          expect(harness.socket.writes, isEmpty);
        },
      );
    }
  });

  group('application acknowledgment ownership', () {
    for (final mode in ['before_completion', 'after_completion', 'mixed']) {
      test(
        'multiple pending acknowledgments $mode wait and use one explicit saved-result continuation',
        () async {
          final harness = await _Harness.open();
          final application = _Application(harness.connection, lane: 'workers');
          addTearDown(application.close);
          addTearDown(harness.close);
          final finished = application.run();
          harness.connection.create(_request, streamId: 'workers');
          harness.socket.emit(
            _shared('response.created', id: 'resp_parent', lane: 'workers'),
          );
          harness.socket.emit(_call('call_alpha', '/root', 0));
          harness.socket.emit(_call('call_beta', '/root/sub', 1));
          // A duplicate completion for an observed call never reruns the tool.
          harness.socket.emit(
            _call('call_alpha', '/root', 0)..['sequence_number'] = 5,
          );
          await _tick();
          expect(application.pending, 2);
          expect(application.toolRuns, {'call_alpha': 1, 'call_beta': 1});
          expect(harness.socket.frames, hasLength(3));
          final sentInput =
              (harness.socket.frames.last['input'] as List<dynamic>)
                  .cast<Object?>();
          if (mode != 'after_completion') {
            harness.socket.emit(_accepted('resp_parent', lane: 'workers'));
            await _tick();
            expect(application.pending, 1);
          }
          if (mode == 'before_completion') {
            harness.socket.emit(
              _failed('resp_parent', sentInput, lane: 'workers'),
            );
            await _tick();
            expect(application.pending, 0);
            expect(harness.socket.frames, hasLength(3));
          }
          harness.socket.emit(
            _shared('response.completed', id: 'resp_parent', lane: 'workers'),
          );
          await _tick();
          if (mode != 'before_completion') {
            expect(harness.socket.frames, hasLength(3));
            expect(application.completedId, 'resp_parent');
            expect(application.pending, mode == 'mixed' ? 1 : 2);
            if (mode == 'after_completion') {
              harness.socket.emit(
                _accepted('resp_parent', lane: 'workers')
                  ..['sequence_number'] = 11,
              );
            }
            harness.socket.emit(
              _failed('resp_parent', sentInput, lane: 'workers')
                ..['sequence_number'] = 12,
            );
          }
          await finished;
          expect(application.pending, 0);
          expect(application.toolRuns, {'call_alpha': 1, 'call_beta': 1});
          final continuation = harness.socket.frames.last;
          expect(harness.socket.frames, hasLength(4));
          expect(continuation['type'], 'response.create');
          expect(continuation['previous_response_id'], 'resp_parent');
          expect(continuation['stream_id'], 'workers');
          expect(continuation['input'], sentInput);
          expect(continuation['max_output_tokens'], 64);
          expect(
            ((continuation['input'] as List<dynamic>).single
                as Map<String, dynamic>)['agent'],
            {'agent_name': '/root/sub'},
          );
          expect(
            harness.socket.frames.where((e) => e['type'] == 'response.inject'),
            hasLength(2),
          );
        },
      );
    }

    test(
      'synchronous acknowledgments are counted before socket write',
      () async {
        final harness = await _Harness.open();
        final application = _Application(harness.connection, lane: 'workers');
        addTearDown(application.close);
        addTearDown(harness.close);
        harness.socket.onWrite = (frame) {
          if (frame['type'] == 'response.inject') {
            expect(application.pending, 1);
            harness.socket.emit(_accepted('resp_parent', lane: 'workers'));
          }
        };
        final finished = application.run();
        harness.connection.create(_request, streamId: 'workers');
        harness.socket.emit(
          _shared('response.created', id: 'resp_parent', lane: 'workers'),
        );
        harness.socket.emit(_call('call_alpha', '/root', 0));
        await _tick();
        expect(application.pending, 0);
        harness.socket.emit(
          _shared('response.completed', id: 'resp_parent', lane: 'workers'),
        );
        await finished;
        expect(harness.socket.frames, hasLength(2));
        expect(application.toolRuns, {'call_alpha': 1});
      },
    );

    test(
      'unrelated response/lane acknowledgments do not satisfy target pending count',
      () async {
        final harness = await _Harness.open();
        final application = _Application(harness.connection, lane: 'workers');
        addTearDown(application.close);
        addTearDown(harness.close);
        final finished = application.run();
        harness.connection.create(_request, streamId: 'workers');
        harness.socket.emit(
          _shared('response.created', id: 'resp_parent', lane: 'workers'),
        );
        harness.socket.emit(_call('call_alpha', '/root', 0));
        await _tick();
        harness.socket.emit(_accepted('resp_other', lane: 'other'));
        harness.socket.emit(
          _shared('response.completed', id: 'resp_other', lane: 'other'),
        );
        harness.socket.emit(
          _shared('response.completed', id: 'resp_parent', lane: 'workers'),
        );
        await _tick();
        expect(application.pending, 1);
        expect(harness.socket.frames, hasLength(2));
        harness.socket.emit(_accepted('resp_parent', lane: 'workers'));
        await finished;
        expect(harness.socket.frames, hasLength(2));
        expect(application.toolRuns, {'call_alpha': 1});
      },
    );

    test(
      'not_found is observable caller ID failure and never creates/resends',
      () async {
        final harness = await _Harness.open();
        final application = _Application(harness.connection, lane: 'workers');
        addTearDown(application.close);
        addTearDown(harness.close);
        final finished = application.run();
        final rejection = expectLater(finished, throwsStateError);
        harness.connection.create(_request, streamId: 'workers');
        harness.socket.emit(
          _shared('response.created', id: 'resp_parent', lane: 'workers'),
        );
        harness.socket.emit(_call('call_alpha', '/root', 0));
        await _tick();
        final sent = (harness.socket.frames.last['input'] as List<dynamic>)
            .cast<Object?>();
        harness.socket.emit(
          _failed(
            'resp_parent',
            sent,
            lane: 'workers',
            code: 'response_not_found',
          ),
        );
        await rejection;
        expect(harness.socket.frames, hasLength(2));
        expect(application.toolRuns, {'call_alpha': 1});
        expect(application.pending, 0);
        expect(
          harness.messages.last,
          isA<ResponseInjectFailedEvent>().having(
            (e) => e.error.code,
            'code',
            ResponseInjectErrorCode.responseNotFound,
          ),
        );
      },
    );

    for (final type in ['response.failed', 'response.incomplete']) {
      test(
        'application reader observes $type promptly without hanging or rerunning',
        () async {
          final harness = await _Harness.open();
          final application = _Application(harness.connection, lane: 'workers');
          addTearDown(application.close);
          addTearDown(harness.close);
          final rejected = expectLater(application.run(), throwsStateError);
          harness.connection.create(_request, streamId: 'workers');
          harness.socket.emit(
            _shared('response.created', id: 'resp_parent', lane: 'workers'),
          );
          harness.socket.emit(_call('call_alpha', '/root', 0));
          await _tick();
          harness.socket.emit(
            _shared(type, id: 'resp_parent', lane: 'workers'),
          );
          await rejected.timeout(const Duration(seconds: 1));
          expect(harness.socket.frames, hasLength(2));
          expect(application.toolRuns, {'call_alpha': 1});
        },
      );
    }

    for (final closeCode in [1000, 1002]) {
      test(
        'generic malformed400 and following close $closeCode both remain observable',
        () async {
          final harness = await _Harness.open();
          addTearDown(harness.close);
          // Raw input deliberately violates the injection schema to exercise
          // the server's generic400 path through the public connection reader.
          harness.socket.sendText(
            jsonEncode({
              'type': 'response.inject',
              'response_id': 'resp_parent',
              'input': 'malformed array',
            }),
          );
          expect(harness.socket.frames.single['input'], 'malformed array');
          harness.socket.emit({
            'type': 'error',
            'status': 400,
            'error': {
              'type': 'invalid_request_error',
              'code': 'invalid_injection',
              'message': 'private malformed request',
            },
          });
          harness.socket.peerClose(closeCode);
          await harness.connection.done;
          await _tick();
          expect(
            harness.messages.single,
            isA<ResponsesErrorEvent>().having((e) => e.status, 'status', 400),
          );
          expect(
            harness.messages.whereType<ResponseInjectFailedEvent>(),
            isEmpty,
          );
          expect(harness.connection.closeCode, closeCode);
          expect(harness.socket.writes, hasLength(1));
          expect(harness.dials, 1);
        },
      );
    }

    test(
      'missing acknowledgment plus disconnect remains unknown, with no fabricated failed event',
      () async {
        final harness = await _Harness.open();
        final application = _Application(harness.connection, lane: 'workers');
        addTearDown(application.close);
        addTearDown(harness.close);
        final rejected = expectLater(application.run(), throwsStateError);
        harness.connection.create(_request, streamId: 'workers');
        harness.socket.emit(
          _shared('response.created', id: 'resp_parent', lane: 'workers'),
        );
        harness.socket.emit(_call('call_alpha', '/root', 0));
        await _tick();
        harness.socket.emit(
          _shared('response.completed', id: 'resp_parent', lane: 'workers'),
        );
        await _tick();
        expect(application.pending, 1);
        harness.socket.peerClose(1006);
        await rejected;
        expect(
          harness.messages.whereType<ResponseInjectFailedEvent>(),
          isEmpty,
        );
        expect(harness.socket.writes, hasLength(2));
        expect(application.toolRuns, {'call_alpha': 1});
      },
    );
  });

  group('injection recovery send ownership', () {
    test(
      'sent injection never replays, new snapshot queues FIFO, overflow rejects only new frame',
      () async {
        final preparation = Completer<ResponsesReconnectDecision>();
        final successor = _Socket();
        final harness = await _Harness.open(
          reconnect: ResponsesReconnectOptions(
            onReconnecting: (_) => preparation.future,
            maxQueueBytes: 512,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
          ),
          successor: successor,
        );
        addTearDown(harness.close);
        harness.connection.inject(
          responseId: 'resp_parent',
          input: const [_saved],
        );
        harness.socket.peerClose(1006);
        final mutable = <Item>[_saved];
        harness.connection.inject(responseId: 'resp_parent', input: mutable);
        harness.connection.inject(responseId: 'resp_parent', input: const []);
        final bytes = harness.connection.recovery!.queuedBytes;
        mutable.clear();
        expect(harness.connection.recovery!.queuedBytes, bytes);
        expect(
          () => harness.connection.inject(
            responseId: 'resp_parent',
            input: [
              FunctionCallOutputItem.string(
                callId: 'oversized',
                output: 'é' * 1000,
              ),
            ],
          ),
          throwsA(isA<ResponsesSendQueueOverflowException>()),
        );
        expect(harness.connection.isClosed, isFalse);
        preparation.complete(const ResponsesReconnectDecision.continueWith());
        await _tick();
        expect(harness.dials, 2);
        expect(harness.socket.writes, hasLength(1));
        expect(successor.frames, [
          {
            'type': 'response.inject',
            'response_id': 'resp_parent',
            'input': [_saved.toJson()],
          },
          {
            'type': 'response.inject',
            'response_id': 'resp_parent',
            'input': <dynamic>[],
          },
        ]);
        expect(harness.connection.recovery!.queuedBytes, 0);
      },
    );

    for (final queued in [false, true]) {
      test(
        'attempted injection failure queued=$queued is terminal and never replayed',
        () async {
          final preparation = Completer<ResponsesReconnectDecision>();
          final successor = _Socket();
          final harness = await _Harness.open(
            reconnect: ResponsesReconnectOptions(
              onReconnecting: (_) => preparation.future,
              initialDelay: Duration.zero,
              maxDelay: Duration.zero,
            ),
            successor: successor,
          );
          addTearDown(harness.close);
          if (queued) {
            harness.socket.peerClose(1006);
            harness.connection.inject(
              responseId: 'resp_parent',
              input: const [_saved],
            );
            harness.connection.inject(
              responseId: 'resp_parent',
              input: const [],
            );
            successor.onWrite = (_) =>
                throw StateError('private write failure');
            preparation.complete(
              const ResponsesReconnectDecision.continueWith(),
            );
          } else {
            harness.socket.onWrite = (_) =>
                throw StateError('private write failure');
            expect(
              () => harness.connection.inject(
                responseId: 'resp_parent',
                input: const [_saved],
              ),
              throwsA(isA<ResponsesDeliveryUnknownException>()),
            );
          }
          final report = await harness.connection.recovery!.done;
          await harness.connection.done;
          expect(report.cause, 'delivery_unknown');
          expect(harness.dials, queued ? 2 : 1);
          expect((queued ? successor : harness.socket).writes, hasLength(1));
          expect(report.unsentMessages, hasLength(queued ? 1 : 0));
          if (queued) {
            expect(report.unsentMessages.single.message['input'], isEmpty);
          }
          expect(
            report.unsentMessages.any((e) => e.text.contains('saved result')),
            isFalse,
          );
        },
      );
    }
  });
}

const _request = CreateResponseRequest(
  model: 'gpt-6.1-sol',
  input: ResponseInput.text('Offline multi-agent fixture'),
  store: true,
  multiAgent: MultiAgentConfig(enabled: true, maxConcurrentSubagents: 1),
);

Map<String, dynamic> _accepted(String responseId, {String? lane}) => {
  'type': 'response.inject.created',
  'response_id': responseId,
  'sequence_number': 7,
  'stream_id': ?lane,
};
Map<String, dynamic> _failed(
  String responseId,
  List<Object?> input, {
  String? lane,
  String code = 'response_already_completed',
}) => {
  'type': 'response.inject.failed',
  'response_id': responseId,
  'sequence_number': 8,
  'stream_id': ?lane,
  'input': input,
  'error': {'code': code, 'message': 'private input not committed'},
};

Map<String, dynamic> _shared(String type, {required String id, String? lane}) {
  final frame = responsesWebSocketEventFixtures().singleWhere(
    (event) => event['type'] == type,
  );
  (frame['response'] as Map<String, dynamic>)['id'] = id;
  frame['sequence_number'] = type == 'response.created' ? 1 : 10;
  if (lane != null) frame['stream_id'] = lane;
  return frame;
}

Map<String, dynamic> _call(String callId, String agent, int index) => {
  'type': 'response.output_item.done',
  'sequence_number': 3 + index,
  'stream_id': 'workers',
  'output_index': index,
  'agent': {'agent_name': agent},
  'item': {
    'type': 'function_call',
    'id': 'item_$callId',
    'call_id': callId,
    'name': 'lookup',
    'arguments': '{}',
    'status': 'completed',
    'agent': {'agent_name': agent},
  },
};

/// This fixture application owns execution, acknowledgment counts and explicit
/// continuation. The SDK deliberately does not add these policies.
class _Application {
  _Application(this.connection, {required this.lane})
    : reader = StreamIterator(connection.events);
  final ResponsesConnection connection;
  final String? lane;
  final StreamIterator<ResponsesServerEvent> reader;
  final Map<String, int> toolRuns = {};
  final List<Map<String, dynamic>> uncommitted = [];
  int pending = 0;
  String? responseId;
  String? completedId;

  Future<void> run() async {
    while (await reader.moveNext()) {
      final message = reader.current;
      if (message.streamId != lane) continue;
      switch (message) {
        case ResponsesStreamEvent(event: ResponseCreatedEvent(:final response)):
          responseId ??= response.id;
        case ResponsesStreamEvent(
          event: OutputItemDoneEvent(
            item: final FunctionCallOutputItemResponse item,
          ),
        ):
          if (toolRuns.containsKey(item.callId)) continue;
          if (responseId == null) {
            throw StateError('Tool call preceded response.created');
          }
          toolRuns[item.callId] = 1;
          final output = FunctionCallOutputItem.string(
            callId: item.callId,
            output: 'saved ${item.callId}',
            agent: item.agent,
          );
          pending++; // Synchronous sends may emit an acknowledgment immediately.
          connection.inject(responseId: responseId!, input: [output]);
        case ResponseInjectCreatedEvent(:final responseId):
          if (responseId == this.responseId) pending--;
        case ResponseInjectFailedEvent(
          :final responseId,
          :final input,
          :final error,
        ):
          if (responseId != this.responseId) continue;
          pending--;
          if (error.code != ResponseInjectErrorCode.responseAlreadyCompleted) {
            throw StateError('Injection target or input rejected');
          }
          for (final item in input) {
            if (item is! Map<String, dynamic>) {
              throw StateError('Uncommitted input requires correction');
            }
            uncommitted.add(item);
          }
        case ResponsesStreamEvent(
          event: ResponseCompletedEvent(:final response),
        ):
          if (response.id == responseId) completedId = response.id;
        case ResponsesStreamEvent(
          event: ResponseFailedEvent() || ResponseIncompleteEvent(),
        ):
          throw StateError(
            'Response ended before successful injection completion',
          );
        case ResponsesErrorEvent():
          throw StateError('Malformed injection request rejected');
        default:
          break;
      }
      if (completedId != null && pending == 0) {
        if (uncommitted.isNotEmpty) {
          connection.create(
            CreateResponseRequest(
              model: 'gpt-6.1-sol',
              previousResponseId: completedId,
              input: ResponseInput.fromOutputItems(uncommitted),
              maxOutputTokens: 64,
              multiAgent: const MultiAgentConfig(enabled: true),
            ),
            streamId: lane,
          );
        }
        return;
      }
    }
    throw StateError('Connection closed with an unknown injection outcome');
  }

  Future<void> close() => reader.cancel();
}

class _BadOutput extends FunctionCallOutputItem {
  _BadOutput()
    : super(
        callId: 'private call',
        output: const FunctionCallOutputString('private result'),
      );
  final List<int> _calls = [0];
  int get serializations => _calls.single;
  @override
  Map<String, dynamic> toJson() {
    _calls[0]++;
    return {
      'type': 'function_call_output',
      'call_id': 'private call',
      'output': Object(),
    };
  }
}

class _BadEvent extends ResponseInjectEvent {
  const _BadEvent() : super(responseId: 'private response', input: const []);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'response.inject',
    'response_id': 'private response',
    'input': Object(),
  };
}

Future<void> _tick() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Harness {
  _Harness(this.client, this.socket);
  final OpenAIClient client;
  final _Socket socket;
  late final ResponsesConnection connection;
  late final StreamSubscription<ResponsesServerEvent> subscription;
  final List<ResponsesServerEvent> messages = [];
  final List<Object> errors = [];
  int dials = 0;

  static Future<_Harness> open({
    bool beta = true,
    ResponsesReconnectOptions? reconnect,
    _Socket? successor,
  }) async {
    final client = OpenAIClient(
      config: const OpenAIConfig(baseUrl: 'https://example.invalid/v1'),
    );
    final harness = _Harness(client, _Socket());
    final connection = await client.responses.connect(
      beta: beta,
      reconnect: reconnect,
      connector: (uri, {headers}) async {
        harness.dials++;
        return harness.dials == 1 ? harness.socket : successor ?? _Socket();
      },
    );
    harness
      ..connection = connection
      ..subscription = connection.events.listen(
        harness.messages.add,
        onError: harness.errors.add,
      );
    return harness;
  }

  Future<void> close() async {
    await connection.close();
    await connection.done;
    await subscription.cancel();
    client.close();
  }
}

class _Socket implements ws.WebSocket {
  final StreamController<ws.WebSocketEvent> _events = StreamController(
    sync: true,
  );
  final List<String> writes = [];
  void Function(Map<String, dynamic>)? onWrite;
  bool _closed = false;
  List<Map<String, dynamic>> get frames => [
    for (final text in writes) jsonDecode(text) as Map<String, dynamic>,
  ];
  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    if (_closed) throw ws.WebSocketConnectionClosed();
    writes.add(text);
    onWrite?.call(jsonDecode(text) as Map<String, dynamic>);
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('text fixture');
  void emit(Map<String, dynamic> frame) =>
      _events.add(ws.TextDataReceived(jsonEncode(frame)));
  void peerClose(int? code) {
    if (_closed) return;
    _closed = true;
    _events.add(ws.CloseReceived(code, 'local close'));
    unawaited(_events.close());
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    if (!_closed) peerClose(code ?? 1000);
  }
}
