import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

import '../fixtures/responses_websocket_events.dart';

const _request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Offline monitoring regression'),
);

Map<String, dynamic> _details() => {
  'detailed_explanation': 'private block explanation',
  'error_type': 'future monitoring classification',
  'review_target': 'private.review:target',
  'steer': {
    'message': 'private passive instruction',
    'future': {
      'private token': [true, null],
    },
  },
  'future': false,
};

Map<String, dynamic> _fixture(String type, String lane, {bool beta = false}) {
  final frame = responsesWebSocketEventFixtures().singleWhere(
    (value) => value['type'] == type,
  )..['stream_id'] = lane;
  if (beta) frame['agent'] = {'agent_name': 'private beta agent'};
  if (frame['response'] case final Map<String, dynamic> response) {
    response['id'] = 'resp_$lane';
  }
  return frame;
}

Map<String, dynamic> _wsBlock({bool beta = false}) => {
  'type': 'error',
  'stream_id': 'blocked',
  'status': 403,
  'sequence_number': 3,
  if (beta) 'agent': null,
  'error': {
    'type': 'forbidden',
    'code': 'misalignment_policy_violation',
    'param': null,
    'message': 'private block message',
    'headers': {'private token': 'private header'},
    'misalignment': _details(),
  },
};

Future<ResponsesServerEvent> _receive(
  _Socket socket,
  StreamIterator<ResponsesServerEvent> iterator,
  Map<String, dynamic> frame,
) async {
  final next = iterator.moveNext();
  socket.emit(frame);
  expect(await next.timeout(const Duration(seconds: 5)), isTrue);
  return iterator.current;
}

void _checkPassiveDetails(ResponsesMisalignmentDetails? details) {
  expect(details, isNotNull);
  expect(details!.errorType, 'future monitoring classification');
  expect(details.detailedExplanation, 'private block explanation');
  expect(details.reviewTarget, 'private.review:target');
  expect(details.steer?.message, 'private passive instruction');
  expect(details.toJson(), _details());
  for (final secret in [
    'private block explanation',
    'future monitoring classification',
    'private.review:target',
    'private passive instruction',
    'private token',
  ]) {
    expect(details.toString(), isNot(contains(secret)));
    expect(details.steer.toString(), isNot(contains(secret)));
  }
}

void main() {
  for (final beta in [false, true]) {
    for (final recover in [false, true]) {
      for (final failureType in ['error', 'response.failed']) {
        test(
          '${beta ? 'beta' : 'GA'} ${recover ? 'opt-in recovery' : 'default'} '
          '$failureType leaves other lanes usable without replay',
          () async {
            final client = OpenAIClient(
              config: const OpenAIConfig(
                baseUrl: 'https://example.invalid/v1',
                authProvider: ApiKeyProvider('offline-fixture'),
              ),
            );
            final socket = _Socket();
            var dials = 0;
            var recoveryPreparations = 0;
            final connection = await client.responses.connect(
              beta: beta,
              reconnect: recover
                  ? ResponsesReconnectOptions(
                      initialDelay: Duration.zero,
                      maxDelay: Duration.zero,
                      onReconnecting: (_) {
                        recoveryPreparations++;
                        return const ResponsesReconnectDecision.continueWith();
                      },
                    )
                  : null,
              connector: (uri, {headers}) async {
                dials++;
                expect(uri.toString(), 'wss://example.invalid/v1/responses');
                expect(headers?['authorization'], 'Bearer offline-fixture');
                expect(
                  headers?['openai-beta'],
                  beta ? 'responses_multi_agent=v1' : null,
                );
                return socket;
              },
            );
            final iterator = StreamIterator(connection.events);
            try {
              expect(connection.recovery != null, recover);
              connection
                ..create(_request, streamId: 'blocked')
                ..create(_request, streamId: 'other');
              final submitted = socket.frames;
              expect(submitted.map((frame) => frame['type']), [
                'response.create',
                'response.create',
              ]);
              expect(submitted.map((frame) => frame['stream_id']), [
                'blocked',
                'other',
              ]);

              final output =
                  await _receive(
                        socket,
                        iterator,
                        _fixture(
                          'response.output_text.delta',
                          'blocked',
                          beta: beta,
                        ),
                      )
                      as ResponsesStreamEvent;
              expect(output.event, isA<OutputTextDeltaEvent>());
              expect(output.streamId, 'blocked');
              expect((output.event as OutputTextDeltaEvent).delta, 'In');

              // A completed tool call is still caller-owned; the client does
              // not submit tool output, acknowledge, steer, or execute it.
              final toolCall =
                  await _receive(socket, iterator, {
                        'type': 'response.output_item.done',
                        'stream_id': 'blocked',
                        'output_index': 0,
                        'sequence_number': 2,
                        'item': {
                          'type': 'function_call',
                          'id': 'fc_fixture',
                          'call_id': 'call_fixture',
                          'name': 'caller_owned_tool',
                          'arguments': '{}',
                          'status': 'completed',
                        },
                      })
                      as ResponsesStreamEvent;
              expect(toolCall.event, isA<OutputItemDoneEvent>());
              expect(toolCall.streamId, 'blocked');
              expect(socket.frames, submitted);

              final wire = failureType == 'error'
                  ? _wsBlock(beta: beta)
                  : _fixture('response.failed', 'blocked', beta: beta);
              if (failureType == 'response.failed') {
                (wire['response'] as Map<String, dynamic>)['error'] = {
                  'code': 'misalignment_policy_violation',
                  'message': 'private block message',
                  'misalignment': _details(),
                };
              }
              final event = await _receive(socket, iterator, wire);
              expect(event.streamId, 'blocked');
              ResponsesMisalignmentDetails? details;
              if (event is ResponsesErrorEvent) {
                expect(event.status, 403);
                expect(event.sequenceNumber, 3);
                expect(event.error.code, 'misalignment_policy_violation');
                expect(event.error.param, isNull);
                expect(event.error.headers, {
                  'private token': 'private header',
                });
                expect(event.hasAgent, beta);
                details = event.error.misalignment;
                expect(event.toJson(), wire);
              } else {
                final failed =
                    (event as ResponsesStreamEvent).event
                        as ResponseFailedEvent;
                expect(failed.isFinal, isTrue);
                expect(failed.response.status, ResponseStatus.failed);
                expect(
                  failed.response.error?.code,
                  'misalignment_policy_violation',
                );
                details = failed.response.error?.misalignment;
                expect(event.toJson(), wire);
              }
              _checkPassiveDetails(details);
              final httpError = createApiException(
                statusCode: 403,
                message: 'private block message',
                code: 'misalignment_policy_violation',
                requestId: 'req_local',
                body: {'error': _wsBlock()['error']},
              );
              expect(httpError, isA<PermissionDeniedException>());
              expect(httpError.misalignment, details);
              expect(httpError.misalignment!.hashCode, details.hashCode);
              final rest = Response.fromJson({
                ...(_fixture('response.failed', 'blocked')['response']
                    as Map<String, dynamic>),
                'error': {
                  'code': 'misalignment_policy_violation',
                  'message': 'private block message',
                  'misalignment': _details(),
                },
              });
              expect(rest.error?.misalignment, details);

              // Give any recovery callback a turn, then inspect transport facts.
              await Future<void>.delayed(Duration.zero);
              expect(connection.isClosed, isFalse);
              expect(socket.closeCalls, 0);
              expect(dials, 1);
              expect(recoveryPreparations, 0);
              expect(socket.frames, submitted);

              final otherOutput =
                  await _receive(
                        socket,
                        iterator,
                        _fixture(
                          'response.output_text.delta',
                          'other',
                          beta: beta,
                        ),
                      )
                      as ResponsesStreamEvent;
              expect(otherOutput.streamId, 'other');
              expect(otherOutput.event, isA<OutputTextDeltaEvent>());
              final complete =
                  await _receive(
                        socket,
                        iterator,
                        _fixture('response.completed', 'other', beta: beta),
                      )
                      as ResponsesStreamEvent;
              expect(complete.streamId, 'other');
              expect(complete.event, isA<ResponseCompletedEvent>());
              expect(complete.event.isFinal, isTrue);
              expect(socket.frames, submitted);
              expect(connection.isClosed, isFalse);
              expect(socket.closeCalls, 0);
              expect(dials, 1);
              expect(recoveryPreparations, 0);

              // Further explicit caller work can still use the same socket.
              connection.create(_request, streamId: 'other');
              expect(socket.frames, hasLength(3));
              expect(socket.frames.last['type'], 'response.create');
              expect(socket.frames.last['stream_id'], 'other');
              expect(dials, 1);
            } finally {
              await iterator.cancel();
              await connection.close();
              await connection.done;
              client.close();
            }
            expect(socket.closeCalls, 1);
          },
        );
      }
    }
  }

  test(
    'malformed optional WS details stay a protocol failure and socket survives',
    () async {
      final socket = _Socket();
      final client = OpenAIClient();
      var dials = 0;
      final connection = await client.responses.connect(
        connector: (uri, {headers}) async {
          dials++;
          return socket;
        },
      );
      final iterator = StreamIterator(connection.events);
      try {
        final wire = _wsBlock();
        ((wire['error'] as Map<String, dynamic>)['misalignment']
                as Map<String, dynamic>)['review_target'] =
            'private invalid\n';
        final next = iterator.moveNext();
        socket.emit(wire);
        await expectLater(
          next,
          throwsA(
            isA<ResponsesProtocolException>().having(
              (error) => error.kind,
              'kind',
              'invalid_event',
            ),
          ),
        );
        expect(connection.isClosed, isFalse);
        expect(socket.closeCalls, 0);
        expect(socket.frames, isEmpty);
        expect(dials, 1);
      } finally {
        await iterator.cancel();
        await connection.close();
        client.close();
      }
    },
  );
}

class _Socket implements ws.WebSocket {
  final _events = StreamController<ws.WebSocketEvent>(sync: true);
  final List<String> _writes = [];
  bool _closed = false;
  int closeCalls = 0;

  List<Map<String, dynamic>> get frames => [
    for (final text in _writes) jsonDecode(text) as Map<String, dynamic>,
  ];

  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    if (_closed) throw ws.WebSocketConnectionClosed();
    _writes.add(text);
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('text fixture');

  void emit(Map<String, dynamic> frame) =>
      _events.add(ws.TextDataReceived(jsonEncode(frame)));

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    if (_closed) return;
    _closed = true;
    _events.add(ws.CloseReceived(code ?? 1000, reason ?? 'fixture closed'));
    await _events.close();
  }
}
