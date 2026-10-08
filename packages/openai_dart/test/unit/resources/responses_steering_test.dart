import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  group('public Responses steering writes', () {
    test(
      'sendSteer and steer emit exactly three fields without changing create',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        final void Function(ResponsesCreateEvent) existingSend =
            harness.connection.send;
        existingSend(const ResponsesCreateEvent(request: _initialRequest));
        harness.connection
          ..sendSteer(
            const ResponsesSteerEvent(
              previousResponseId: 'resp_parent',
              input: ResponsesSteerInput.text('First correction'),
            ),
          )
          ..steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('Second correction'),
          );
        expect(harness.socket.frames, [
          {..._initialRequest.toJson(), 'type': 'response.create'},
          {
            'type': 'response.steer',
            'previous_response_id': 'resp_parent',
            'input': 'First correction',
          },
          {
            'type': 'response.steer',
            'previous_response_id': 'resp_parent',
            'input': 'Second correction',
          },
        ]);
        expect(harness.connectorCalls, 1);
      },
    );

    test(
      'typed user text, image and file messages keep the request projection',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        const input = ResponsesSteerInput.messages([
          ResponsesSteerMessage.text('Consider these saved inputs.'),
          ResponsesSteerMessage.parts([
            ResponsesSteerContentPart.text('Read these references.'),
            ResponsesSteerContentPart.image(
              imageUrl: 'https://example.invalid/image.png',
            ),
            ResponsesSteerContentPart.file(fileId: 'file_saved'),
          ]),
        ]);
        harness.connection.steer(
          previousResponseId: 'resp_parent',
          input: input,
        );
        final frame = harness.socket.frames.single;
        expect(frame.keys.toSet(), {'type', 'previous_response_id', 'input'});
        expect(frame['input'], input.toJson());
        for (final message in frame['input'] as List<dynamic>) {
          final object = message as Map<String, dynamic>;
          expect(
            object.keys.every({'type', 'role', 'content'}.contains),
            isTrue,
          );
          expect(object['role'], 'user');
        }
        expect(jsonEncode(frame), isNot(contains('stream_id')));
      },
    );

    for (final invalidInput in <Object?>[
      null,
      1,
      <dynamic>[],
      [
        {'role': 'assistant', 'content': 'private rejected text'},
      ],
      [
        {'role': 'user', 'content': 'private text', 'id': 'private id'},
      ],
      [
        {'role': 'user', 'content': 'private text', 'status': 'completed'},
      ],
      [
        {
          'type': 'function_call_output',
          'call_id': 'call_saved',
          'output': 'saved',
        },
      ],
      [
        {
          'role': 'user',
          'content': [
            {'type': 'input_video', 'video_url': 'private url'},
          ],
        },
      ],
    ]) {
      test(
        'malformed writable steering never reaches the socket: ${invalidInput.runtimeType}',
        () async {
          final harness = await _Harness.open();
          addTearDown(harness.close);
          expect(
            () => harness.connection.sendSteer(
              ResponsesSteerEvent.fromJson({
                'type': 'response.steer',
                'previous_response_id': 'resp_parent',
                'input': invalidInput,
              }),
            ),
            throwsFormatException,
          );
          expect(harness.socket.frames, isEmpty);
          expect(harness.connection.isClosed, isFalse);
        },
      );
    }

    for (final extra in ['stream_id', 'model', 'tools', 'id', 'status']) {
      test(
        'steer request rejects unsupported top-level $extra without a write',
        () async {
          final harness = await _Harness.open();
          addTearDown(harness.close);
          expect(
            () => harness.connection.sendSteer(
              ResponsesSteerEvent.fromJson({
                'type': 'response.steer',
                'previous_response_id': 'resp_parent',
                'input': 'Keep scope small.',
                extra: 'private extra',
              }),
            ),
            throwsFormatException,
          );
          expect(harness.socket.frames, isEmpty);
        },
      );
    }

    test(
      'send failure is redacted and never queues or retries steering',
      () async {
        final harness = await _Harness.open(failSend: true);
        addTearDown(harness.close);
        expect(
          () => harness.connection.steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('private correction'),
          ),
          throwsA(
            isA<ResponsesTransportException>().having(
              (e) => e.toString(),
              'safe error',
              isNot(contains('private')),
            ),
          ),
        );
        await harness.connection.done;
        await _tick();
        expect(harness.socket.sendAttempts, 1);
        expect(harness.socket.frames, isEmpty);
        expect(harness.connectorCalls, 1);
        expect(harness.errors.single, isA<ResponsesTransportException>());
      },
    );

    test(
      'closed connection rejects both steering entry points eagerly',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        await harness.connection.close();
        expect(
          () => harness.connection.steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('correction'),
          ),
          throwsStateError,
        );
        expect(
          () => harness.connection.sendSteer(
            const ResponsesSteerEvent(
              previousResponseId: 'resp_parent',
              input: ResponsesSteerInput.text('correction'),
            ),
          ),
          throwsStateError,
        );
        expect(harness.socket.sendAttempts, 0);
      },
    );
  });

  group('public steering ownership and continuation protocol', () {
    for (final terminalType in ['response.incomplete', 'response.completed']) {
      for (final lane in <String?>[null, 'planner']) {
        test(
          'automatic successor after $terminalType on lane=$lane never creates or resends input',
          () async {
            final harness = await _Harness.open();
            addTearDown(harness.close);
            harness.connection.create(_initialRequest, streamId: lane);
            harness.socket.emit(
              _responseEvent('response.created', 'resp_parent', lane: lane),
            );
            await _tick();
            harness.connection.steer(
              previousResponseId: 'resp_parent',
              input: const ResponsesSteerInput.text('accepted correction'),
            );
            harness.socket.emit(_accepted('steer_saved', lane: lane));
            await _tick();
            expect(harness.events.last, isA<ResponsesSteerAcceptedEvent>());
            expect(
              harness.socket.frames.length,
              2,
              reason: 'Acceptance does not send a create.',
            );
            harness.socket
              ..emit(_responseEvent(terminalType, 'resp_parent', lane: lane))
              ..emit(
                _responseEvent(
                  'response.created',
                  'resp_successor',
                  lane: lane,
                ),
              )
              ..emit(
                _responseEvent(
                  'response.completed',
                  'resp_successor',
                  lane: lane,
                ),
              );
            await _tick();
            expect(harness.events.map((e) => e.type), [
              'response.created',
              'response.steer.accepted',
              terminalType,
              'response.created',
              'response.completed',
            ]);
            final completed = harness.events.last as ResponsesStreamEvent;
            expect(
              (completed.event as ResponseCompletedEvent).response.id,
              'resp_successor',
            );
            if (terminalType == 'response.incomplete') {
              final incomplete =
                  (harness.events[2] as ResponsesStreamEvent).event
                      as ResponseIncompleteEvent;
              expect(incomplete.response.incompleteDetails!.reason, 'steered');
            }
            expect(
              harness.socket.frames
                  .where((e) => e['type'] == 'response.create')
                  .length,
              1,
            );
            expect(
              harness.socket.frames
                  .where((e) => e['type'] == 'response.steer')
                  .length,
              1,
            );
            expect(harness.connection.isClosed, isFalse);
            expect(harness.errors, isEmpty);
          },
        );
      }
    }

    test(
      'all seven pending stubs use one explicit saved-result create on the original lane',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        harness.connection.create(_initialRequest, streamId: 'planner');
        harness.socket.emit(
          _responseEvent('response.created', 'resp_parent', lane: 'planner'),
        );
        await _tick();
        harness.connection.steer(
          previousResponseId: 'resp_parent',
          input: const ResponsesSteerInput.text('accepted correction'),
        );
        harness.socket
          ..emit(_accepted('steer_saved', lane: 'planner'))
          ..emit(
            _responseEvent(
              'response.completed',
              'resp_parent',
              lane: 'planner',
            ),
          )
          ..emit(_pending('steer_saved', _requiredStubs, lane: 'planner'));
        await _tick();
        final pending = harness.events.last as ResponsesSteerPendingEvent;
        expect(
          pending.requiredInput.map((stub) => stub.toJson()).toList(),
          _requiredStubs,
        );
        expect(pending.steer.previousResponseId, 'resp_parent');
        expect(pending.streamId, 'planner');
        expect(harness.socket.frames.length, 2);
        final savedResults = _savedResults();
        harness.connection.create(
          CreateResponseRequest(
            model: 'gpt-6-sol',
            previousResponseId: pending.steer.previousResponseId,
            input: ResponseInput.fromOutputItems(savedResults),
            instructions: 'Explicit continuation settings.',
          ),
          streamId: pending.streamId,
        );
        final continuation = harness.socket.frames.last;
        expect(continuation['previous_response_id'], 'resp_parent');
        expect(continuation['stream_id'], 'planner');
        expect(continuation['instructions'], 'Explicit continuation settings.');
        expect(continuation['input'], savedResults);
        expect(
          jsonEncode(continuation),
          isNot(contains('accepted correction')),
        );
        expect((continuation['input'] as List<dynamic>).length, 7);
        harness.socket
          ..emit(
            _responseEvent(
              'response.created',
              'resp_successor',
              lane: 'planner',
            ),
          )
          ..emit(
            _responseEvent(
              'response.completed',
              'resp_successor',
              lane: 'planner',
            ),
          );
        await _tick();
        expect(harness.socket.frames.length, 3);
        expect(
          harness.socket.frames
              .where((e) => e['type'] == 'response.steer')
              .length,
          1,
        );
        expect(harness.connectorCalls, 1);
        expect(harness.errors, isEmpty);
      },
    );

    test(
      'matching create before pending requires no notification or extra create',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        harness.connection.create(_initialRequest, streamId: 'planner');
        harness.socket.emit(
          _responseEvent('response.created', 'resp_parent', lane: 'planner'),
        );
        await _tick();
        harness.connection.steer(
          previousResponseId: 'resp_parent',
          input: const ResponsesSteerInput.text('accepted correction'),
        );
        harness.socket
          ..emit(_accepted('steer_saved', lane: 'planner'))
          ..emit(
            _responseEvent(
              'response.completed',
              'resp_parent',
              lane: 'planner',
            ),
          );
        await _tick();
        harness.connection.create(
          CreateResponseRequest(
            model: 'gpt-6-sol',
            previousResponseId: 'resp_parent',
            input: ResponseInput.fromOutputItems([_savedResults().first]),
          ),
          streamId: 'planner',
        );
        harness.socket
          ..emit(
            _responseEvent(
              'response.created',
              'resp_successor',
              lane: 'planner',
            ),
          )
          ..emit(
            _responseEvent(
              'response.completed',
              'resp_successor',
              lane: 'planner',
            ),
          );
        await _tick();
        expect(harness.events.whereType<ResponsesSteerPendingEvent>(), isEmpty);
        expect(harness.socket.frames.length, 3);
        expect(
          harness.socket.frames
              .where((e) => e['type'] == 'response.create')
              .length,
          2,
        );
        expect(harness.errors, isEmpty);
      },
    );

    test(
      'repeated pending submissions for one parent do not multiply continuations',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        harness.connection.create(_initialRequest, streamId: 'planner');
        harness.socket.emit(
          _responseEvent('response.created', 'resp_parent', lane: 'planner'),
        );
        await _tick();
        harness.connection
          ..steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('correction one'),
          )
          ..steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('correction two'),
          );
        harness.socket
          ..emit(_accepted('steer_one', lane: 'planner'))
          ..emit(_accepted('steer_two', lane: 'planner'))
          ..emit(
            _responseEvent(
              'response.completed',
              'resp_parent',
              lane: 'planner',
            ),
          )
          ..emit(_pending('steer_one', [_requiredStubs.first], lane: 'planner'))
          ..emit(
            _pending('steer_two', [_requiredStubs.first], lane: 'planner'),
          );
        await _tick();
        final pending = harness.events
            .whereType<ResponsesSteerPendingEvent>()
            .toList();
        expect(pending.map((e) => e.steer.id), ['steer_one', 'steer_two']);
        expect(
          pending[0].requiredInput.single.toJson(),
          pending[1].requiredInput.single.toJson(),
        );
        expect(harness.socket.frames.length, 3);
        harness.connection.create(
          CreateResponseRequest(
            model: 'gpt-6-sol',
            previousResponseId: 'resp_parent',
            input: ResponseInput.fromOutputItems([_savedResults().first]),
          ),
          streamId: 'planner',
        );
        harness.socket.emit(
          _responseEvent('response.created', 'resp_successor', lane: 'planner'),
        );
        await _tick();
        expect(harness.socket.frames.length, 4);
        expect(
          harness.socket.frames
              .where((e) => e['type'] == 'response.create')
              .length,
          2,
        );
        expect(
          jsonEncode(harness.socket.frames.last),
          isNot(contains('correction')),
        );
      },
    );

    for (final allocated in [false, true]) {
      test(
        'failed submission allocated=$allocated preserves submitted input and never resends',
        () async {
          final harness = await _Harness.open();
          addTearDown(harness.close);
          harness.connection.steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('correction'),
          );
          if (allocated) {
            harness.socket.emit(_accepted('steer_saved', lane: 'planner'));
          }
          final failed = {
            'type': 'response.steer.failed',
            'sequence_number': 9,
            'stream_id': 'planner',
            'steer': {
              if (allocated) 'id': 'steer_saved',
              'previous_response_id': 'resp_parent',
              'input': 'correction',
            },
            'error': {
              'type': 'invalid_request_error',
              'code': allocated
                  ? 'successor_creation_failed'
                  : 'future_rejected_code',
              'message': 'private failure',
            },
          };
          harness.socket.emit(failed);
          await _tick();
          final event = harness.events.last as ResponsesSteerFailedEvent;
          expect(event.toJson(), failed);
          expect(event.steer.id, allocated ? 'steer_saved' : null);
          expect(event.steer.input, 'correction');
          expect(
            event.error.code,
            allocated ? 'successor_creation_failed' : 'future_rejected_code',
          );
          expect(event.toString(), isNot(contains('private failure')));
          expect(harness.socket.frames.length, 1);
          expect(harness.connection.isClosed, isFalse);
        },
      );
    }

    for (final acknowledged in [false, true]) {
      test(
        'disconnect acknowledged=$acknowledged leaves outcome unknown without replay',
        () async {
          final harness = await _Harness.open();
          addTearDown(harness.close);
          harness.connection.steer(
            previousResponseId: 'resp_parent',
            input: const ResponsesSteerInput.text('correction'),
          );
          if (acknowledged) harness.socket.emit(_accepted('steer_saved'));
          harness.socket.peerClose();
          await harness.connection.done;
          await _tick();
          expect(
            harness.events.whereType<ResponsesSteerFailedEvent>(),
            isEmpty,
          );
          expect(
            harness.events.whereType<ResponsesSteerAcceptedEvent>().length,
            acknowledged ? 1 : 0,
          );
          expect(harness.socket.frames.length, 1);
          expect(harness.connectorCalls, 1);
          expect(harness.connection.closeCode, 1006);
        },
      );
    }

    test(
      'missing acknowledgment on an open socket is not fabricated as rejection',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        harness.connection.steer(
          previousResponseId: 'resp_parent',
          input: const ResponsesSteerInput.text('correction'),
        );
        harness.socket.emit(
          _responseEvent('response.completed', 'resp_parent'),
        );
        await _tick();
        expect(
          harness.events.whereType<ResponsesSteerAcceptedEvent>(),
          isEmpty,
        );
        expect(harness.events.whereType<ResponsesSteerFailedEvent>(), isEmpty);
        expect(harness.socket.frames.length, 1);
        expect(harness.connection.isClosed, isFalse);
      },
    );

    test(
      'malformed steering acknowledgment is a protocol error with no automatic write',
      () async {
        final harness = await _Harness.open();
        addTearDown(harness.close);
        harness.connection.steer(
          previousResponseId: 'resp_parent',
          input: const ResponsesSteerInput.text('correction'),
        );
        harness.socket
          ..emit(_pending('steer_saved', const []))
          ..emit(_accepted('steer_saved'));
        await _tick();
        expect(
          harness.errors.single,
          isA<ResponsesProtocolException>().having(
            (e) => e.kind,
            'classification',
            'invalid_event',
          ),
        );
        expect(harness.events.single, isA<ResponsesSteerAcceptedEvent>());
        expect(harness.socket.frames.length, 1);
        expect(harness.connection.isClosed, isFalse);
      },
    );
  });
}

const _initialRequest = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Local initial input'),
);

Map<String, dynamic> _accepted(String id, {String? lane}) => {
  'type': 'response.steer.accepted',
  'sequence_number': 2,
  'steer': {'id': id, 'previous_response_id': 'resp_parent'},
  'stream_id': ?lane,
};

Map<String, dynamic> _pending(
  String id,
  List<Map<String, dynamic>> required, {
  String? lane,
}) => {
  'type': 'response.steer.pending',
  'sequence_number': 4,
  'steer': {'id': id, 'previous_response_id': 'resp_parent'},
  'reason': 'waiting_for_required_input',
  'required_input': required,
  'stream_id': ?lane,
};

Map<String, dynamic> _responseEvent(String type, String id, {String? lane}) => {
  'type': type,
  'sequence_number': 3,
  'stream_id': ?lane,
  'response': {
    'id': id,
    'object': 'response',
    'created_at': 1,
    'status': type == 'response.created'
        ? 'in_progress'
        : type == 'response.incomplete'
        ? 'incomplete'
        : 'completed',
    'model': 'gpt-6-sol',
    'output': <dynamic>[],
    'access_programs': null,
    'error': null,
    'incomplete_details': type == 'response.incomplete'
        ? {'reason': 'steered'}
        : null,
    'instructions': null,
    'tools': <dynamic>[],
    'parallel_tool_calls': false,
    'metadata': <String, dynamic>{},
    'tool_choice': 'auto',
    'temperature': 1.0,
    'top_p': 1.0,
  },
};

const _requiredStubs = <Map<String, dynamic>>[
  {
    'type': 'function_call_output',
    'call_id': 'call_function',
    'name': 'get_status',
  },
  {'type': 'custom_tool_call_output', 'call_id': 'call_custom'},
  {'type': 'computer_call_output', 'call_id': 'call_computer'},
  {'type': 'shell_call_output', 'call_id': 'call_shell'},
  {'type': 'apply_patch_call_output', 'call_id': 'call_patch'},
  {
    'type': 'tool_search_output',
    'call_id': 'call_search',
    'execution': 'client',
  },
  {'type': 'mcp_approval_response', 'approval_request_id': 'approval_saved'},
];

List<Map<String, dynamic>> _savedResults() => [
  {
    'type': 'function_call_output',
    'call_id': 'call_function',
    'output': 'Saved function result',
  },
  {
    'type': 'custom_tool_call_output',
    'call_id': 'call_custom',
    'output': 'Saved custom result',
  },
  {
    'type': 'computer_call_output',
    'call_id': 'call_computer',
    'output': {
      'type': 'computer_screenshot',
      'image_url': 'data:image/png;base64,c2F2ZWQ=',
    },
    'acknowledged_safety_checks': [
      {
        'id': 'safety_saved',
        'code': 'irreversible_action',
        'message': 'Saved acknowledgement',
      },
    ],
  },
  {
    'type': 'shell_call_output',
    'call_id': 'call_shell',
    'output': [
      {
        'stdout': 'Saved stdout',
        'stderr': '',
        'outcome': {'type': 'exit', 'exit_code': 0},
      },
    ],
  },
  {
    'type': 'apply_patch_call_output',
    'call_id': 'call_patch',
    'status': 'completed',
    'output': 'Saved patch result',
  },
  {
    'type': 'tool_search_output',
    'call_id': 'call_search',
    'execution': 'client',
    'tools': <dynamic>[],
  },
  {
    'type': 'mcp_approval_response',
    'approval_request_id': 'approval_saved',
    'approve': true,
  },
];

Future<void> _tick() => Future<void>.delayed(Duration.zero);

class _Harness {
  _Harness(this.client, this.socket);
  final OpenAIClient client;
  final _Socket socket;
  late final ResponsesConnection connection;
  late final StreamSubscription<ResponsesServerEvent> subscription;
  final List<ResponsesServerEvent> events = [];
  final List<Object> errors = [];
  int connectorCalls = 0;

  static Future<_Harness> open({bool failSend = false}) async {
    final result = _Harness(
      OpenAIClient(
        config: const OpenAIConfig(baseUrl: 'https://example.invalid/v1'),
      ),
      _Socket(failSend: failSend),
    );
    final connection = await result.client.responses.connect(
      connector: (uri, {headers}) async {
        result.connectorCalls++;
        expect(uri.toString(), 'wss://example.invalid/v1/responses');
        expect(headers, isEmpty);
        return result.socket;
      },
    );
    result
      ..connection = connection
      ..subscription = connection.events.listen(
        result.events.add,
        onError: result.errors.add,
      );
    return result;
  }

  Future<void> close() async {
    try {
      await connection.close();
    } finally {
      await subscription.cancel();
      client.close();
    }
  }
}

class _Socket implements ws.WebSocket {
  _Socket({this.failSend = false});
  final bool failSend;
  final StreamController<ws.WebSocketEvent> controller = StreamController();
  final List<Map<String, dynamic>> frames = [];
  int sendAttempts = 0;

  void emit(Map<String, dynamic> frame) =>
      controller.add(ws.TextDataReceived(jsonEncode(frame)));
  void peerClose() {
    controller.add(ws.CloseReceived(1006, 'local disconnect'));
    unawaited(controller.close());
  }

  @override
  Stream<ws.WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    sendAttempts++;
    if (failSend) throw ws.WebSocketException('private socket failure');
    frames.add(jsonDecode(text) as Map<String, dynamic>);
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('Text only');
  @override
  Future<void> close([int? code, String? reason]) async {
    if (controller.isClosed) return;
    await (controller..add(ws.CloseReceived(code ?? 1000, reason ?? '')))
        .close();
  }
}
