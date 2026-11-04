import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

const _request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Offline fixture'),
);

void main() {
  group('Responses WebSocket sessions', () {
    test(
      'routes interleaved lanes in order without hiding raw events',
      () async {
        final fixture = await _fixture();
        final planner = fixture.session.lane('planner');
        final critic = fixture.session.lane('critic');
        final defaultLane = fixture.session.lane();
        final observed = <ResponsesServerEvent>[];
        final observer = fixture.connection.events.listen(observed.add);
        addTearDown(observer.cancel);

        fixture.socket.frame(_notice('planner', 1));
        fixture.socket.frame(_notice('critic', 2));
        fixture.socket.frame(_notice(null, 3));
        fixture.socket.frame(_notice('unregistered', 4));
        fixture.socket.frame(_notice('planner', 5));

        expect((await planner.receive()).rawJson['number'], 1);
        expect((await critic.receive()).rawJson['number'], 2);
        expect((await defaultLane.receive()).rawJson['number'], 3);
        expect((await planner.receive()).rawJson['number'], 5);
        await _pump();
        expect(observed.map((event) => event.rawJson['number']), [
          1,
          2,
          3,
          4,
          5,
        ]);
        expect(observed, everyElement(isA<UnknownResponsesServerEvent>()));
      },
    );

    test('warmup returns an ID for explicit tool-turn continuation', () async {
      final fixture = await _fixture();
      final lane = fixture.session.lane('main')
        ..create(_request, generate: false);
      expect(fixture.socket.sent.single, {
        ..._request.toJson(),
        'type': 'response.create',
        'stream_id': 'main',
        'generate': false,
      });
      _complete(fixture.socket, 'main', 'warmup');
      final warmup = await lane.getFinalResponse();
      expect(warmup.id, 'warmup');
      expect(warmup.output, isEmpty);
      expect(lane.finalResponse?.id, 'warmup');

      final continuation = _request.copyWith(
        previousResponseId: warmup.id,
        input: ResponseInput.items([
          FunctionCallOutputItem.string(
            callId: 'call_local',
            output: 'Local result',
          ),
        ]),
      );
      lane.create(continuation);
      expect(lane.finalResponse, isNull);
      final sent = fixture.socket.sent.last;
      expect(sent['previous_response_id'], 'warmup');
      expect(sent['input'], [
        {
          'type': 'function_call_output',
          'call_id': 'call_local',
          'output': 'Local result',
        },
      ]);
      expect(sent.containsKey('generate'), isFalse);
      expect(sent.containsKey('stream'), isFalse);
      expect(sent.containsKey('background'), isFalse);
      _complete(fixture.socket, 'main', 'continued');
      expect((await lane.getFinalResponse()).id, 'continued');
    });

    for (final terminal in ['completed', 'failed', 'incomplete']) {
      for (final output in ['omitted', 'null', 'empty', 'nonempty']) {
        test(
          '$terminal final output $output preserves authoritative items',
          () async {
            final fixture = await _fixture();
            final lane = fixture.session.lane('main');
            fixture.socket.frame(_responseEvent('created', 'main', 'response'));
            fixture.socket.frame(_done('main', 2, _tool()));
            fixture.socket.frame(_done('main', 0, _refusal()));
            final response = _response('response', terminal);
            switch (output) {
              case 'omitted':
                response.remove('output');
              case 'null':
                response['output'] = null;
              case 'empty':
                response['output'] = <dynamic>[];
              case 'nonempty':
                response['output'] = [_message('authoritative')];
            }
            fixture.socket.frame({
              'type': 'response.$terminal',
              'stream_id': 'main',
              'sequence_number': 4,
              'response': response,
            });
            final finalResponse = await lane.getFinalResponse();
            expect(finalResponse.id, 'response');
            expect(finalResponse.status.toJson(), terminal);
            final finalItems = finalResponse.output
                .map((item) => item.toJson())
                .toList();
            expect(finalItems, switch (output) {
              'omitted' || 'null' => [_refusal(), _tool()],
              'empty' => <dynamic>[],
              _ => [_message('authoritative')],
            });
            expect(lane.finalResponse, same(finalResponse));
          },
        );
      }
    }

    test(
      'terminal response is retained when EOF follows immediately',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        _complete(fixture.socket, 'main', 'last');
        fixture.socket.peerClose();
        expect((await lane.getFinalResponse()).id, 'last');
        await expectLater(lane.receive(), throwsA(_kind('unexpected_eof')));
        await fixture.connection.done;
      },
    );

    test('EOF wakes an unfinished final-response wait', () async {
      final fixture = await _fixture();
      final lane = fixture.session.lane('main');
      final finalResponse = lane.getFinalResponse();
      final assertion = expectLater(
        finalResponse,
        throwsA(_kind('unexpected_eof')),
      );
      fixture.socket.frame(_responseEvent('created', 'main', 'unfinished'));
      fixture.socket.peerClose();
      await assertion;
    });

    test(
      'API errors expose their envelope and do not damage other lanes',
      () async {
        final fixture = await _fixture();
        final failed = fixture.session.lane('failed');
        final healthy = fixture.session.lane('healthy');
        fixture.socket.frame({
          'type': 'error',
          'stream_id': 'failed',
          'status': 400,
          'error': {
            'type': 'invalid_request_error',
            'code': 'local_fixture',
            'param': null,
            'message': 'private fixture diagnostics',
          },
        });
        await expectLater(
          failed.getFinalResponse(),
          throwsA(
            _kind('request_error')
                .having(
                  (error) => error.event?.streamId,
                  'error lane',
                  'failed',
                )
                .having(
                  (error) => error.toString(),
                  'redacted diagnostics',
                  isNot(contains('private fixture diagnostics')),
                ),
          ),
        );
        _complete(fixture.socket, 'healthy', 'success');
        expect((await healthy.getFinalResponse()).id, 'success');
      },
    );

    test('only one wait owns a lane at a time', () async {
      final fixture = await _fixture();
      final lane = fixture.session.lane('main');
      final pending = lane.receive();
      await expectLater(Future.sync(lane.getFinalResponse), throwsStateError);
      fixture.socket.frame(_notice('main', 1));
      expect((await pending).rawJson['number'], 1);
      _complete(fixture.socket, 'main', 'next');
      expect((await lane.getFinalResponse()).id, 'next');
    });

    test('precompleted cancellation leaves queued events untouched', () async {
      final fixture = await _fixture();
      final lane = fixture.session.lane('main');
      fixture.socket.frame(_notice('main', 1));
      await _pump();
      await expectLater(
        lane.receive(abortTrigger: Future<void>.value()),
        throwsA(_kind('cancelled')),
      );
      expect((await lane.receive()).rawJson['number'], 1);
    });

    test(
      'repeated cancelled waits release the reader for later events',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        for (var attempt = 0; attempt < 20; attempt++) {
          final abort = Completer<void>();
          final assertion = expectLater(
            lane.receive(abortTrigger: abort.future),
            throwsA(_kind('cancelled')),
          );
          await _pump();
          abort.complete();
          await assertion;
        }
        fixture.socket.frame(_notice('main', 21));
        expect((await lane.receive()).rawJson['number'], 21);
        _complete(fixture.socket, 'main', 'resumed');
        expect((await lane.getFinalResponse()).id, 'resumed');
      },
    );

    test(
      'final collection returns the cached result after terminal receive',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        _complete(fixture.socket, 'main', 'cached');
        expect((await lane.receive()).type, 'response.created');
        expect((await lane.receive()).type, 'response.completed');
        final cached = lane.finalResponse;
        expect(cached?.id, 'cached');
        expect(await lane.getFinalResponse(), same(cached));
        expect(await lane.getFinalResponse(), same(cached));
      },
    );

    test(
      'cancellation releases a wait and keeps partial final state',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        final abort = Completer<void>();
        final pending = lane.getFinalResponse(abortTrigger: abort.future);
        final assertion = expectLater(pending, throwsA(_kind('cancelled')));
        fixture.socket.frame(_responseEvent('created', 'main', 'partial'));
        fixture.socket.frame(_done('main', 0, _refusal()));
        await _pump();
        abort.complete();
        await assertion;
        final terminal = _response('partial', 'completed')..remove('output');
        fixture.socket.frame({
          'type': 'response.completed',
          'stream_id': 'main',
          'response': terminal,
        });
        expect(
          (await lane.getFinalResponse()).output.single.toJson(),
          _refusal(),
        );
      },
    );

    test(
      'lane detach wakes its reader and keeps socket and siblings open',
      () async {
        final fixture = await _fixture();
        final detached = fixture.session.lane('detached');
        final healthy = fixture.session.lane('healthy');
        final pending = detached.receive();
        final assertion = expectLater(pending, throwsA(_kind('lane_detached')));
        detached
          ..close()
          ..close();
        await assertion;
        expect(fixture.socket.closeCalls, 0);
        expect(() => fixture.session.lane('detached'), throwsStateError);
        _complete(fixture.socket, 'healthy', 'success');
        expect((await healthy.getFinalResponse()).id, 'success');
      },
    );

    test(
      'session close detaches readers while direct connection stays usable',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        final pending = lane.receive();
        final assertion = expectLater(
          pending,
          throwsA(_kind('session_closed')),
        );
        await fixture.session.close();
        await fixture.session.close();
        await assertion;
        expect(fixture.socket.closeCalls, 0);
        expect(fixture.connection.isClosed, isFalse);
        fixture.connection.create(_request, streamId: 'direct');
        expect(fixture.socket.sent.last['stream_id'], 'direct');
        final replacement = ResponsesWebSocketSession(
          fixture.connection,
          limits: _limits(),
        );
        addTearDown(replacement.close);
        expect(() => replacement.lane('main'), throwsStateError);
        final fresh = replacement.lane('fresh');
        fixture.socket.frame(_notice('fresh', 7));
        expect((await fresh.receive()).rawJson['number'], 7);
      },
    );

    test(
      'a second active session and a closed connection are rejected',
      () async {
        final fixture = await _fixture();
        expect(
          () =>
              ResponsesWebSocketSession(fixture.connection, limits: _limits()),
          throwsStateError,
        );
        await fixture.session.close();
        await fixture.connection.close();
        expect(
          () =>
              ResponsesWebSocketSession(fixture.connection, limits: _limits()),
          throwsStateError,
        );
      },
    );

    test(
      'recovery connections cannot route lane writes through a replay queue',
      () async {
        final socket = _Socket();
        final client = OpenAIClient();
        final connection = await client.responses.connect(
          connector: (uri, {headers}) async => socket,
          reconnect: ResponsesReconnectOptions(
            onReconnecting: (_) => const ResponsesReconnectDecision.abort(),
          ),
        );
        addTearDown(() async {
          await connection.close();
          client.close();
        });
        expect(
          () => ResponsesWebSocketSession(connection, limits: _limits()),
          throwsArgumentError,
        );
        expect(socket.sent, isEmpty);
        expect(socket.closeCalls, 0);
        expect(connection.isClosed, isFalse);
      },
    );

    for (final malformed in [
      'negative_output_index',
      'mismatched_response_id',
    ]) {
      test('$malformed fails only its accumulator lane', () async {
        final fixture = await _fixture();
        final invalid = fixture.session.lane('invalid');
        final healthy = fixture.session.lane('healthy');
        fixture.socket.frame(_responseEvent('created', 'invalid', 'started'));
        if (malformed == 'negative_output_index') {
          fixture.socket.frame(_done('invalid', -1, _tool()));
        } else {
          fixture.socket.frame(_responseEvent('completed', 'invalid', 'other'));
        }
        await expectLater(
          invalid.getFinalResponse(),
          throwsA(_kind('invalid_response')),
        );
        _complete(fixture.socket, 'healthy', 'success');
        expect((await healthy.getFinalResponse()).id, 'success');
        expect(fixture.connection.isClosed, isFalse);
      });
    }

    test(
      'editing a delivered item cannot alter the separately collected output',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        fixture.socket.frame(_responseEvent('created', 'main', 'response'));
        fixture.socket.frame(_done('main', 0, _refusal()));
        await lane.receive();
        final delivered = await lane.receive() as ResponsesStreamEvent;
        final item =
            (delivered.event as OutputItemDoneEvent).item as MessageOutputItem;
        item.content.clear();
        final terminal = _response('response', 'completed')..remove('output');
        fixture.socket.frame({
          'type': 'response.completed',
          'stream_id': 'main',
          'response': terminal,
        });
        final result = await lane.getFinalResponse();
        expect(result.output.single.toJson(), _refusal());
        expect(result.output.clear, throwsUnsupportedError);
      },
    );

    for (final status in ['completed', 'failed', 'incomplete']) {
      for (final beforeCollection in [true, false]) {
        test(
          '$status terminal edits ${beforeCollection ? 'before' : 'after'} collection cannot alter the final snapshot',
          () async {
            final fixture = await _fixture();
            final lane = fixture.session.lane('main');
            ResponsesStreamEvent? delivered;
            if (beforeCollection) {
              final observer = fixture.connection.events.listen((event) {
                if (event is ResponsesStreamEvent &&
                    event.type == 'response.$status') {
                  delivered = event;
                  _editTerminalCollections(_terminalResponse(event));
                }
              });
              addTearDown(observer.cancel);
            }
            final wire = _response('response', status)
              ..['output'] = [_message('Wire-authoritative output')]
              ..['metadata'] = {'origin': 'wire'};
            fixture.socket.frame({
              'type': 'response.$status',
              'stream_id': 'main',
              'response': wire,
            });
            if (beforeCollection) {
              await _pump();
              expect(delivered, isNotNull);
            } else {
              delivered = await lane.receive() as ResponsesStreamEvent;
              _editTerminalCollections(_terminalResponse(delivered!));
            }
            final finalResponse = await lane.getFinalResponse();
            expect(finalResponse.outputText, 'Wire-authoritative output');
            expect(finalResponse.metadata, {'origin': 'wire'});
            expect(finalResponse.status.value, status);
            expect(
              ((delivered!.rawJson['response'] as Map)['output'] as List)
                  .single,
              _message('Wire-authoritative output'),
            );
          },
        );
      }
    }

    test('lane IDs are validated and every reserved slot counts', () async {
      final fixture = await _fixture(limits: _limits(maxLanes: 2));
      for (final id in ['', 'with space', 'line\n', 'é', 'a' * 257]) {
        expect(() => fixture.session.lane(id), throwsArgumentError);
      }
      fixture.session.lane();
      fixture.session.lane('named').close();
      expect(
        () => fixture.session.lane('third'),
        throwsA(_kind('buffer_limit')),
      );
      expect(() => fixture.session.lane('named'), throwsStateError);
    });

    test(
      'mismatched sends and overlapping creates leave no extra write',
      () async {
        final fixture = await _fixture();
        final lane = fixture.session.lane('main');
        expect(
          () => lane.send(
            const ResponsesCreateEvent(request: _request, streamId: 'other'),
          ),
          throwsArgumentError,
        );
        expect(fixture.socket.sent, isEmpty);
        lane.create(_request);
        expect(() => lane.create(_request), throwsStateError);
        expect(fixture.socket.sent, hasLength(1));
        _complete(fixture.socket, 'main', 'finished');
        await lane.getFinalResponse();
        lane.create(_request);
        expect(fixture.socket.sent, hasLength(2));
      },
    );

    test('invalid GA multi-agent preflight leaves its lane usable', () async {
      final fixture = await _fixture();
      final lane = fixture.session.lane('main');
      final invalid = _request.copyWith(
        multiAgent: const MultiAgentConfig(enabled: true),
      );
      expect(() => lane.create(invalid), throwsArgumentError);
      expect(fixture.socket.sent, isEmpty);
      lane.create(_request);
      expect(fixture.socket.sent, hasLength(1));
      expect(fixture.socket.sent.single.containsKey('multi_agent'), isFalse);
      _complete(fixture.socket, 'main', 'valid');
      expect((await lane.getFinalResponse()).id, 'valid');
    });

    test('per-lane event overflow releases only the slow lane', () async {
      final fixture = await _fixture(limits: _limits(maxEventsPerLane: 1));
      final slow = fixture.session.lane('slow');
      final healthy = fixture.session.lane('healthy');
      fixture.socket.frame(_notice('slow', 1));
      fixture.socket.frame(_notice('slow', 2));
      fixture.socket.frame(_notice('healthy', 3));
      await _pump();
      await expectLater(slow.receive(), throwsA(_kind('buffer_limit')));
      expect((await healthy.receive()).rawJson['number'], 3);
      expect(fixture.socket.closeCalls, 0);
    });

    test(
      'per-lane byte limits count UTF-8 rather than string length',
      () async {
        final frame = _notice('slow', 1)..['payload'] = '€' * 80;
        final encoded = jsonEncode(frame);
        expect(utf8.encode(encoded).length, greaterThan(encoded.length));
        final fixture = await _fixture(
          limits: _limits(maxBytesPerLane: encoded.length),
        );
        final slow = fixture.session.lane('slow');
        final healthy = fixture.session.lane('healthy');
        fixture.socket.frame(frame);
        fixture.socket.frame(_notice('healthy', 2));
        await _pump();
        await expectLater(slow.receive(), throwsA(_kind('buffer_limit')));
        expect((await healthy.receive()).rawJson['number'], 2);
      },
    );

    test('shared event pressure evicts the largest backlog only', () async {
      final fixture = await _fixture(limits: _limits(maxEvents: 3));
      final slow = fixture.session.lane('slow');
      final healthy = fixture.session.lane('healthy');
      for (var index = 0; index < 3; index++) {
        fixture.socket.frame(_notice('slow', index));
      }
      fixture.socket.frame(_notice('healthy', 4));
      await _pump();
      await expectLater(slow.receive(), throwsA(_kind('buffer_limit')));
      expect((await healthy.receive()).rawJson['number'], 4);
      fixture.socket.frame(_notice('healthy', 5));
      expect((await healthy.receive()).rawJson['number'], 5);
    });

    test('shared byte pressure frees the largest backlog counters', () async {
      final slowFrame = _notice('slow', 1)..['payload'] = '€' * 70;
      final healthyFrame = _notice('healthy', 3);
      final limit = 2 * _bytes(slowFrame) + _bytes(healthyFrame) - 1;
      final fixture = await _fixture(limits: _limits(maxBytes: limit));
      final slow = fixture.session.lane('slow');
      final healthy = fixture.session.lane('healthy');
      fixture.socket.frame(slowFrame);
      fixture.socket.frame(slowFrame);
      fixture.socket.frame(healthyFrame);
      await _pump();
      await expectLater(slow.receive(), throwsA(_kind('buffer_limit')));
      expect((await healthy.receive()).rawJson['number'], 3);
      fixture.socket.frame(healthyFrame);
      expect((await healthy.receive()).rawJson['number'], 3);
    });

    test(
      'response budget bounds consumed data even with an empty queue',
      () async {
        final created = _responseEvent('created', 'slow', 'large');
        final delta = _notice('slow', 1)..['payload'] = 'x' * 100;
        final fixture = await _fixture(
          limits: _limits(
            maxResponseBytes: _bytes(created) + 2 * _bytes(delta) - 1,
          ),
        );
        final slow = fixture.session.lane('slow');
        final healthy = fixture.session.lane('healthy');
        fixture.socket.frame(created);
        expect((await slow.receive()).type, 'response.created');
        fixture.socket.frame(delta);
        expect((await slow.receive()).type, 'fixture.notice');
        fixture.socket.frame(delta);
        await expectLater(slow.receive(), throwsA(_kind('response_limit')));
        _complete(fixture.socket, 'healthy', 'small');
        expect((await healthy.getFinalResponse()).id, 'small');
      },
    );

    test('malformed messages release pending helper readers', () async {
      final fixture = await _fixture();
      final lane = fixture.session.lane('main');
      final assertion = expectLater(
        lane.receive(),
        throwsA(
          anyOf(
            isA<ResponsesProtocolException>(),
            isA<ResponsesWebSocketSessionException>(),
          ),
        ),
      );
      fixture.socket.controller.add(ws.TextDataReceived('{broken'));
      await assertion;
      expect(fixture.connection.isClosed, isFalse);
      fixture.connection.create(_request);
      expect(fixture.socket.sent, hasLength(1));
    });

    for (final field in [
      'lanes',
      'laneEvents',
      'events',
      'laneBytes',
      'bytes',
      'responseBytes',
    ]) {
      test('rejects a zero $field limit in release mode', () async {
        final fixture = await _fixture();
        await fixture.session.close();
        expect(
          () => ResponsesWebSocketSession(
            fixture.connection,
            limits: _limits(
              maxLanes: field == 'lanes' ? 0 : 8,
              maxEventsPerLane: field == 'laneEvents' ? 0 : 16,
              maxEvents: field == 'events' ? 0 : 64,
              maxBytesPerLane: field == 'laneBytes' ? 0 : 65536,
              maxBytes: field == 'bytes' ? 0 : 262144,
              maxResponseBytes: field == 'responseBytes' ? 0 : 65536,
            ),
          ),
          throwsArgumentError,
        );
      });
    }
  });
}

TypeMatcher<ResponsesWebSocketSessionException> _kind(String kind) =>
    isA<ResponsesWebSocketSessionException>().having(
      (error) => error.kind,
      'kind',
      kind,
    );

Response _terminalResponse(ResponsesStreamEvent event) => switch (event.event) {
  ResponseCompletedEvent(:final response) => response,
  ResponseFailedEvent(:final response) => response,
  ResponseIncompleteEvent(:final response) => response,
  _ => throw StateError('Expected terminal response'),
};

void _editTerminalCollections(Response response) {
  (response.output.single as MessageOutputItem).content.clear();
  // Parsed metadata may already be immutable. Either way, attempted edits must
  // leave the separately collected final response's wire snapshot intact.
  try {
    response.metadata!['origin'] = 'edited';
  } on UnsupportedError {
    // The original parser's immutable metadata is equally safe.
  }
}

ResponsesWebSocketLimits _limits({
  int maxLanes = 8,
  int maxEventsPerLane = 16,
  int maxEvents = 64,
  int maxBytesPerLane = 65536,
  int maxBytes = 262144,
  int maxResponseBytes = 65536,
}) => ResponsesWebSocketLimits(
  maxLanes: maxLanes,
  maxEventsPerLane: maxEventsPerLane,
  maxEvents: maxEvents,
  maxBytesPerLane: maxBytesPerLane,
  maxBytes: maxBytes,
  maxResponseBytes: maxResponseBytes,
);

Future<_Fixture> _fixture({ResponsesWebSocketLimits? limits}) async {
  final socket = _Socket();
  final client = OpenAIClient();
  final connection = await client.responses.connect(
    connector: (uri, {headers}) async => socket,
  );
  final session = ResponsesWebSocketSession(
    connection,
    limits: limits ?? _limits(),
  );
  addTearDown(() async {
    await session.close();
    await connection.close();
    client.close();
  });
  return _Fixture(socket, connection, session);
}

class _Fixture {
  const _Fixture(this.socket, this.connection, this.session);

  final _Socket socket;
  final ResponsesConnection connection;
  final ResponsesWebSocketSession session;
}

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

int _bytes(Map<String, dynamic> frame) => utf8.encode(jsonEncode(frame)).length;

Map<String, dynamic> _notice(String? lane, int number) => {
  'type': 'fixture.notice',
  'stream_id': ?lane,
  'number': number,
};

Map<String, dynamic> _response(String id, String status) => {
  'id': id,
  'object': 'response',
  'created_at': 1,
  'status': status,
  'output': <dynamic>[],
};

Map<String, dynamic> _responseEvent(String kind, String lane, String id) => {
  'type': 'response.$kind',
  'stream_id': lane,
  'sequence_number': 1,
  'response': _response(id, kind == 'created' ? 'in_progress' : kind),
};

void _complete(_Socket socket, String lane, String id) {
  socket
    ..frame(_responseEvent('created', lane, id))
    ..frame(_responseEvent('completed', lane, id));
}

Map<String, dynamic> _done(String lane, int index, Map<String, dynamic> item) =>
    {
      'type': 'response.output_item.done',
      'stream_id': lane,
      'sequence_number': index + 2,
      'output_index': index,
      'item': item,
    };

Map<String, dynamic> _tool() => {
  'type': 'function_call',
  'id': 'function',
  'call_id': 'call_local',
  'name': 'lookup',
  'arguments': '{"key":"value"}',
  'status': 'completed',
};

Map<String, dynamic> _refusal() => {
  'type': 'message',
  'id': 'refusal',
  'role': 'assistant',
  'status': 'completed',
  'content': [
    {'type': 'refusal', 'refusal': 'Offline refusal fixture'},
  ],
};

Map<String, dynamic> _message(String text) => {
  'type': 'message',
  'id': 'message',
  'role': 'assistant',
  'status': 'completed',
  'content': [
    {'type': 'output_text', 'text': text, 'annotations': <dynamic>[]},
  ],
};

class _Socket implements ws.WebSocket {
  final StreamController<ws.WebSocketEvent> controller = StreamController();
  final List<Map<String, dynamic>> sent = [];
  int closeCalls = 0;

  void frame(Map<String, dynamic> frame) =>
      controller.add(ws.TextDataReceived(jsonEncode(frame)));

  void peerClose() {
    controller.add(ws.CloseReceived(1000, ''));
    unawaited(controller.close());
  }

  @override
  Stream<ws.WebSocketEvent> get events => controller.stream;

  @override
  String get protocol => '';

  @override
  void sendText(String text) =>
      sent.add(jsonDecode(text) as Map<String, dynamic>);

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('No binary sends.');

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    if (!controller.isClosed) {
      controller.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
      unawaited(controller.close());
    }
  }
}
