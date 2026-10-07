import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final beta in [false, true]) {
    for (final selection in _Selection.values) {
      for (final effective in _Effective.values) {
        test('create preserves $selection and $effective beta=$beta', () async {
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectCreateRequest(request, selection, beta: beta);
              return _jsonResponse(_responseJson(effective));
            }),
          );
          final request = CreateResponseRequest.fromJson(
            _requestJson(selection),
          );
          expect(request.accessPrograms, _request(selection).accessPrograms);
          final before = request.toJson();
          final response = await client.responses.create(request, beta: beta);
          _expectResponse(response, effective);
          expect(request.toJson(), before);
          expect(sends, 1);
        });

        for (final accumulated in [false, true]) {
          final operation = accumulated ? 'accumulated SSE' : 'SSE';
          test(
            '$operation preserves $selection and $effective beta=$beta',
            () async {
              var sends = 0;
              final client = _client(
                MockClient((request) async {
                  sends++;
                  _expectCreateRequest(
                    request,
                    selection,
                    beta: beta,
                    streaming: true,
                  );
                  return _sseResponse(_events(effective, beta: beta));
                }),
              );
              final request = _request(selection);
              final before = request.toJson();
              final selected = request.accessPrograms;
              final metadata = request.metadata;
              final received = <ResponseStreamEvent>[];
              if (accumulated) {
                await for (final state
                    in client.responses.createStreamWithAccumulator(
                      request,
                      beta: beta,
                    )) {
                  final event = state.latestEvent!;
                  received.add(event);
                  final response = _lifecycleResponse(event);
                  _expectResponse(
                    response,
                    effective,
                    status: _statusFor(event.type),
                  );
                  expect(state.response, same(response));
                  expect(state.status, response.status);
                  expect(state.responseId, 'resp_access_fixture');
                  expect(state.isComplete, event.isFinal);
                  expect(state.isSuccessful, event is ResponseCompletedEvent);
                  expect(state.isFailed, isFalse);
                  expect(state.text, isEmpty);
                  expect(state.reasoning, isEmpty);
                  expect(state.functionArguments, isEmpty);
                  expect(
                    state.usage?.toJson(),
                    event is ResponseCompletedEvent ? _usageJson() : null,
                  );
                }
              } else {
                received.addAll(
                  await client.responses
                      .createStream(request, beta: beta)
                      .toList(),
                );
                for (final event in received) {
                  _expectResponse(
                    _lifecycleResponse(event),
                    effective,
                    status: _statusFor(event.type),
                  );
                  expect(event.isFinal, event is ResponseCompletedEvent);
                  expect(
                    event.finalResponse,
                    event is ResponseCompletedEvent
                        ? same(event.response)
                        : null,
                  );
                }
              }
              expect(received.map((event) => event.type), [
                'response.created',
                'response.queued',
                'response.in_progress',
                'response.completed',
              ]);
              expect(received.whereType<UnknownEvent>(), isEmpty);
              for (final (index, event) in received.indexed) {
                _expectLifecycle(event, beta: beta, sequence: index);
              }
              expect(request.toJson(), before);
              expect(request.stream, isFalse);
              expect(request.accessPrograms, same(selected));
              expect(request.metadata, same(metadata));
              expect(sends, 1);
            },
          );
        }
      }
    }

    for (final terminal in ['response.failed', 'response.incomplete']) {
      for (final effective in _Effective.values) {
        for (final accumulated in [false, true]) {
          final operation = accumulated ? 'accumulated SSE' : 'SSE';
          test(
            '$operation retains $effective in $terminal beta=$beta',
            () async {
              var sends = 0;
              final client = _client(
                MockClient((request) async {
                  sends++;
                  _expectCreateRequest(
                    request,
                    _Selection.blue,
                    beta: beta,
                    streaming: true,
                  );
                  return _sseResponse(
                    _events(effective, beta: beta, terminal: terminal),
                  );
                }),
              );
              if (accumulated) {
                var terminalSeen = false;
                await for (final state
                    in client.responses.createStreamWithAccumulator(
                      _request(_Selection.blue),
                      beta: beta,
                    )) {
                  final event = state.latestEvent!;
                  final response = _lifecycleResponse(event);
                  _expectResponse(
                    response,
                    effective,
                    status: _statusFor(event.type),
                  );
                  expect(state.response, same(response));
                  expect(state.status, response.status);
                  expect(state.isComplete, event.isFinal);
                  expect(state.isSuccessful, isFalse);
                  expect(state.isFailed, event is ResponseFailedEvent);
                  // The existing accumulator exposes usage only on completion;
                  // the complete terminal Response still retains its own usage.
                  expect(state.usage, isNull);
                  if (event.isFinal) {
                    terminalSeen = true;
                    expect(event.type, terminal);
                    expect(event.finalResponse, same(response));
                  }
                }
                expect(terminalSeen, isTrue);
              } else {
                final events = await client.responses
                    .createStream(_request(_Selection.blue), beta: beta)
                    .toList();
                expect(events.last.type, terminal);
                final event = events.last;
                _expectLifecycle(event, beta: beta, sequence: 3);
                _expectResponse(
                  event.finalResponse!,
                  effective,
                  status: _statusFor(terminal),
                );
                expect(event.isFinal, isTrue);
              }
              expect(sends, 1);
            },
          );
        }
      }
    }

    for (final operation in ['retrieve', 'cancel']) {
      for (final effective in _Effective.values) {
        test('$operation retains $effective beta=$beta', () async {
          var sends = 0;
          final status = operation == 'cancel' ? 'cancelled' : 'completed';
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectReadRequest(request, operation, beta: beta);
              return _jsonResponse(_responseJson(effective, status: status));
            }),
          );
          final response = await _readResponse(client, operation, beta: beta);
          _expectResponse(response, effective, status: status);
          expect(sends, 1);
        });
      }
    }

    for (final entry in _malformedAccessPrograms().entries) {
      final (value, cyberError) = entry.value;
      final expected = throwsA(
        isA<FormatException>()
            .having(
              (error) => error.message,
              'response field context',
              contains('Response.access_programs'),
            )
            .having(
              (error) => error.message,
              'nested field context',
              cyberError ? contains('cyber') : isNotEmpty,
            ),
      );
      for (final operation in ['create', 'retrieve', 'cancel']) {
        test('$operation rejects ${entry.key} beta=$beta', () async {
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              if (operation == 'create') {
                _expectCreateRequest(request, _Selection.red, beta: beta);
              } else {
                _expectReadRequest(request, operation, beta: beta);
              }
              return _jsonResponse({
                ..._responseJson(_Effective.red),
                'access_programs': value,
              });
            }),
          );
          await expectLater(
            operation == 'create'
                ? client.responses.create(_request(_Selection.red), beta: beta)
                : _readResponse(client, operation, beta: beta),
            expected,
          );
          expect(sends, 1);
        });
      }

      for (final lifecycle in _lifecycleMatchers.keys) {
        for (final accumulated in [false, true]) {
          final operation = accumulated ? 'accumulated SSE' : 'SSE';
          test(
            '$operation $lifecycle rejects ${entry.key} beta=$beta',
            () async {
              var sends = 0;
              final client = _client(
                MockClient((request) async {
                  sends++;
                  _expectCreateRequest(
                    request,
                    _Selection.red,
                    beta: beta,
                    streaming: true,
                  );
                  return _sseResponse([
                    {
                      'type': lifecycle,
                      'sequence_number': 0,
                      'response': {
                        ..._responseJson(
                          _Effective.red,
                          status: _statusFor(lifecycle),
                        ),
                        'access_programs': value,
                      },
                      if (beta) 'agent': {'agent_name': 'fixture-agent'},
                    },
                  ]);
                }),
              );
              if (accumulated) {
                await expectLater(
                  client.responses
                      .createStreamWithAccumulator(
                        _request(_Selection.red),
                        beta: beta,
                      )
                      .toList(),
                  expected,
                );
              } else {
                await expectLater(
                  client.responses
                      .createStream(_request(_Selection.red), beta: beta)
                      .toList(),
                  expected,
                );
              }
              expect(sends, 1);
            },
          );
        }
      }
    }

    for (final (status, code) in [
      (400, 'invalid_access_program'),
      (400, 'unsupported_access_program'),
      (403, 'access_program_not_enabled'),
    ]) {
      for (final operation in ['create', 'SSE', 'accumulated SSE']) {
        test('$operation maps $code without retry beta=$beta', () async {
          var sends = 0;
          final body = {
            'error': {
              'message': 'Synthetic access-program error.',
              'type': 'invalid_request_error',
              'param': 'access_programs.cyber',
              'code': code,
            },
          };
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectCreateRequest(
                request,
                _Selection.red,
                beta: beta,
                streaming: operation != 'create',
              );
              return http.Response(
                jsonEncode(body),
                status,
                headers: {
                  'content-type': 'application/json',
                  'x-request-id': 'req-access-fixture',
                },
              );
            }),
          );
          final expected = throwsA(
            isA<ApiException>()
                .having(
                  (error) => error,
                  'existing exception mapping',
                  status == 400
                      ? isA<BadRequestException>()
                      : isA<PermissionDeniedException>(),
                )
                .having((error) => error.statusCode, 'status', status)
                .having((error) => error.code, 'code', code)
                .having((error) => error.type, 'type', 'invalid_request_error')
                .having(
                  (error) => error.param,
                  'param',
                  'access_programs.cyber',
                )
                .having(
                  (error) => error.requestId,
                  'request ID',
                  'req-access-fixture',
                )
                .having((error) => error.body, 'complete error body', body),
          );
          switch (operation) {
            case 'create':
              await expectLater(
                client.responses.create(_request(_Selection.red), beta: beta),
                expected,
              );
            case 'SSE':
              await expectLater(
                client.responses
                    .createStream(_request(_Selection.red), beta: beta)
                    .toList(),
                expected,
              );
            case 'accumulated SSE':
              await expectLater(
                client.responses
                    .createStreamWithAccumulator(
                      _request(_Selection.red),
                      beta: beta,
                    )
                    .toList(),
                expected,
              );
          }
          expect(sends, 1);
        });
      }
    }

    for (final accumulated in [false, true]) {
      final operation = accumulated ? 'accumulated SSE' : 'SSE';
      test(
        '$operation preserves future event access metadata beta=$beta',
        () async {
          var sends = 0;
          final future = <String, dynamic>{
            'type': 'response.access_program.future',
            'sequence_number': 1,
            'access_programs': {
              'cyber': 'future_program',
              'future': <Object>[],
            },
            if (beta) 'agent': {'agent_name': 'fixture-agent'},
          };
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectCreateRequest(
                request,
                _Selection.empty,
                beta: beta,
                streaming: true,
              );
              return _sseResponse([
                {
                  'type': 'response.created',
                  'sequence_number': 0,
                  'response': _responseJson(
                    _Effective.blue,
                    status: 'in_progress',
                  ),
                },
                future,
                {
                  'type': 'response.completed',
                  'sequence_number': 2,
                  'response': _responseJson(_Effective.blue),
                },
              ]);
            }),
          );
          final expectedFuture = {...future, '_event': future['type']};
          if (accumulated) {
            var observed = false;
            var completed = false;
            Response? previous;
            await for (final state
                in client.responses.createStreamWithAccumulator(
                  _request(_Selection.empty),
                  beta: beta,
                )) {
              final event = state.latestEvent!;
              if (event is ResponseCreatedEvent) {
                previous = state.response;
              } else if (event is UnknownEvent) {
                observed = true;
                expect(event.rawJson, expectedFuture);
                expect(event.toJson(), expectedFuture);
                expect(event.sequenceNumber, 1);
                expect(state.response, same(previous));
                expect(
                  state.response!.accessPrograms!.cyber,
                  CyberAccessProgram.daybreakBlue,
                );
                expect(state.status, ResponseStatus.inProgress);
                expect(state.isComplete, isFalse);
              } else if (event is ResponseCompletedEvent) {
                completed = true;
                _expectResponse(event.response, _Effective.blue);
              }
            }
            expect(observed, isTrue);
            expect(completed, isTrue);
          } else {
            final events = await client.responses
                .createStream(_request(_Selection.empty), beta: beta)
                .toList();
            final event = events[1] as UnknownEvent;
            expect(event.type, future['type']);
            expect(event.rawJson, expectedFuture);
            expect(event.toJson(), expectedFuture);
            expect(event.sequenceNumber, 1);
            _expectResponse(
              (events.last as ResponseCompletedEvent).response,
              _Effective.blue,
            );
          }
          expect(sends, 1);
        },
      );
    }
  }

  test('list retains every returned access-program shape', () async {
    var sends = 0;
    final client = _client(
      MockClient((request) async {
        sends++;
        _expectListRequest(request);
        return _jsonResponse(
          _listJson([
            for (final effective in _Effective.values) _responseJson(effective),
          ]),
        );
      }),
    );
    final result = await client.responses.list(
      after: 'resp_before',
      limit: 6,
      order: 'asc',
    );
    expect(result.object, 'list');
    expect(result.hasMore, isFalse);
    expect(result.firstId, 'resp_access_fixture');
    expect(result.lastId, 'resp_access_fixture');
    expect(result.data, hasLength(_Effective.values.length));
    for (final (index, effective) in _Effective.values.indexed) {
      _expectResponse(result.data[index], effective);
    }
    expect(sends, 1);
  });

  for (final entry in _malformedAccessPrograms().entries) {
    test('list rejects ${entry.key}', () async {
      var sends = 0;
      final client = _client(
        MockClient((request) async {
          sends++;
          _expectListRequest(request);
          return _jsonResponse(
            _listJson([
              {
                ..._responseJson(_Effective.red),
                'access_programs': entry.value.$1,
              },
            ]),
          );
        }),
      );
      await expectLater(
        client.responses.list(after: 'resp_before', limit: 6, order: 'asc'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'response field context',
            contains('Response.access_programs'),
          ),
        ),
      );
      expect(sends, 1);
    });
  }
}

enum _Selection { omitted, empty, standard, blue, red }

enum _Effective { omitted, nullValue, standard, blue, red, blueWithExtra }

OpenAIClient _client(http.Client mock) {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('fixture-key'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: mock,
  );
  addTearDown(client.close);
  addTearDown(mock.close);
  return client;
}

CreateResponseRequest _request(_Selection selection) => CreateResponseRequest(
  model: 'fixture-model',
  input: const ResponseInput.text('Synthetic access-program request.'),
  maxOutputTokens: 16,
  metadata: const {'fixture': 'access-programs'},
  stream: false,
  accessPrograms: switch (selection) {
    _Selection.omitted => null,
    _Selection.empty => const AccessProgramsParam(),
    _Selection.standard => const AccessProgramsParam(
      cyber: CyberAccessProgram.standard,
    ),
    _Selection.blue => const AccessProgramsParam(
      cyber: CyberAccessProgram.daybreakBlue,
    ),
    _Selection.red => const AccessProgramsParam(
      cyber: CyberAccessProgram.daybreakRed,
    ),
  },
);

Map<String, dynamic> _requestJson(
  _Selection selection, {
  bool streaming = false,
}) => {
  'model': 'fixture-model',
  'input': 'Synthetic access-program request.',
  'max_output_tokens': 16,
  'metadata': {'fixture': 'access-programs'},
  'stream': streaming,
  if (selection != _Selection.omitted)
    'access_programs': switch (selection) {
      _Selection.standard => {'cyber': 'standard'},
      _Selection.blue => {'cyber': 'daybreak_blue'},
      _Selection.red => {'cyber': 'daybreak_red'},
      _Selection.empty || _Selection.omitted => <String, dynamic>{},
    },
};

void _expectProtocol(http.Request request, {required bool beta}) {
  expect(request.headers['Authorization'], 'Bearer fixture-key');
  expect(request.headers['Content-Type'], 'application/json');
  expect(
    request.headers['OpenAI-Beta'],
    beta ? 'responses_multi_agent=v1' : null,
  );
}

void _expectCreateRequest(
  http.Request request,
  _Selection selection, {
  required bool beta,
  bool streaming = false,
}) {
  _expectProtocol(request, beta: beta);
  expect(request.method, 'POST');
  expect(request.url.path, '/v1/responses');
  expect(request.url.queryParameters, beta ? {'beta': 'true'} : isEmpty);
  expect(
    jsonDecode(request.body),
    _requestJson(selection, streaming: streaming),
  );
  if (streaming) expect(request.headers['Accept'], 'text/event-stream');
}

void _expectReadRequest(
  http.Request request,
  String operation, {
  required bool beta,
}) {
  _expectProtocol(request, beta: beta);
  if (operation == 'retrieve') {
    expect(request.method, 'GET');
    expect(request.url.path, '/v1/responses/resp_access_fixture');
    expect(request.url.queryParametersAll, {
      'include[]': [
        'reasoning.encrypted_content',
        'message.output_text.logprobs',
      ],
      if (beta) 'beta': ['true'],
    });
    expect(request.body, isEmpty);
  } else {
    expect(request.method, 'POST');
    expect(request.url.path, '/v1/responses/resp_access_fixture/cancel');
    expect(request.url.queryParameters, beta ? {'beta': 'true'} : isEmpty);
    expect(jsonDecode(request.body), <String, dynamic>{});
  }
}

Future<Response> _readResponse(
  OpenAIClient client,
  String operation, {
  required bool beta,
}) => operation == 'retrieve'
    ? client.responses.retrieve(
        'resp_access_fixture',
        include: const [
          Include.reasoningEncryptedContent,
          Include.messageOutputTextLogprobs,
        ],
        beta: beta,
      )
    : client.responses.cancel('resp_access_fixture', beta: beta);

void _expectListRequest(http.Request request) {
  _expectProtocol(request, beta: false);
  expect(request.method, 'GET');
  expect(request.url.path, '/v1/responses');
  expect(request.url.queryParameters, {
    'after': 'resp_before',
    'limit': '6',
    'order': 'asc',
  });
  expect(request.body, isEmpty);
}

CyberAccessProgram? _effectiveProgram(_Effective effective) =>
    switch (effective) {
      _Effective.omitted || _Effective.nullValue => null,
      _Effective.standard => CyberAccessProgram.standard,
      _Effective.blue ||
      _Effective.blueWithExtra => CyberAccessProgram.daybreakBlue,
      _Effective.red => CyberAccessProgram.daybreakRed,
    };

void _expectResponse(
  Response response,
  _Effective effective, {
  String status = 'completed',
}) {
  final program = _effectiveProgram(effective);
  expect(response.id, 'resp_access_fixture');
  expect(response.object, 'response');
  expect(response.createdAt, 1700000000);
  expect(response.status, ResponseStatus.fromJson(status));
  expect(response.model, 'fixture-model');
  expect(response.metadata, {'fixture': 'access-programs'});
  expect(response.maxOutputTokens, 16);
  expect(response.temperature, 0.5);
  expect(response.topP, 0.9);
  expect(response.parallelToolCalls, isFalse);
  if (program == null) {
    expect(response.accessPrograms, isNull);
    expect(response.toJson().containsKey('access_programs'), isFalse);
  } else {
    expect(response.accessPrograms, AccessProgramsBody(cyber: program));
    expect(response.accessPrograms!.cyber, program);
    expect(response.toJson()['access_programs'], {'cyber': program.toJson()});
    expect(
      Response.fromJson(response.toJson()).accessPrograms,
      response.accessPrograms,
    );
  }
  final finalStatus = [
    'completed',
    'failed',
    'incomplete',
    'cancelled',
  ].contains(status);
  expect(response.outputText, finalStatus ? 'Synthetic reply.' : '');
  expect(response.usage?.toJson(), finalStatus ? _usageJson() : null);
  expect(response.error?.code, status == 'failed' ? 'server_error' : null);
  expect(
    response.error?.message,
    status == 'failed' ? 'Synthetic response failure.' : null,
  );
  expect(
    response.incompleteDetails?.reason,
    status == 'incomplete' ? 'max_output_tokens' : null,
  );
}

final _lifecycleMatchers = <String, Matcher>{
  'response.created': isA<ResponseCreatedEvent>(),
  'response.queued': isA<ResponseQueuedEvent>(),
  'response.in_progress': isA<ResponseInProgressEvent>(),
  'response.completed': isA<ResponseCompletedEvent>(),
  'response.failed': isA<ResponseFailedEvent>(),
  'response.incomplete': isA<ResponseIncompleteEvent>(),
};

Response _lifecycleResponse(ResponseStreamEvent event) => switch (event) {
  ResponseCreatedEvent(:final response) ||
  ResponseQueuedEvent(:final response) ||
  ResponseInProgressEvent(:final response) ||
  ResponseCompletedEvent(:final response) ||
  ResponseFailedEvent(:final response) ||
  ResponseIncompleteEvent(:final response) => response,
  _ => throw StateError('Expected a lifecycle fixture event.'),
};

String _statusFor(String type) => switch (type) {
  'response.created' || 'response.queued' => 'queued',
  'response.in_progress' => 'in_progress',
  'response.completed' => 'completed',
  'response.failed' => 'failed',
  'response.incomplete' => 'incomplete',
  _ => throw StateError('Unknown lifecycle fixture.'),
};

void _expectLifecycle(
  ResponseStreamEvent event, {
  required bool beta,
  required int sequence,
}) {
  expect(event, _lifecycleMatchers[event.type]);
  expect(event.sequenceNumber, sequence);
  expect(
    event.toJson()['agent'],
    beta ? {'agent_name': 'fixture-agent'} : null,
  );
  final response = _lifecycleResponse(event);
  expect(
    (event.toJson()['response'] as Map)['access_programs'],
    response.toJson()['access_programs'],
  );
}

List<Map<String, dynamic>> _events(
  _Effective effective, {
  required bool beta,
  String terminal = 'response.completed',
}) => [
  for (final (sequence, type) in [
    'response.created',
    'response.queued',
    'response.in_progress',
    terminal,
  ].indexed)
    {
      'type': type,
      'sequence_number': sequence,
      'response': _responseJson(effective, status: _statusFor(type)),
      if (beta) 'agent': {'agent_name': 'fixture-agent'},
    },
];

Map<String, dynamic> _responseJson(
  _Effective effective, {
  String status = 'completed',
}) => {
  // Every required member of the canonical GA and beta Response is supplied.
  // Explicit omission is intentional provider compatibility coverage.
  'id': 'resp_access_fixture',
  'object': 'response',
  'created_at': 1700000000,
  'status': status,
  'model': 'fixture-model',
  if (effective != _Effective.omitted)
    'access_programs': effective == _Effective.nullValue
        ? null
        : {
            'cyber': _effectiveProgram(effective)!.toJson(),
            if (effective == _Effective.blueWithExtra)
              'future_domain': {'authorization': 'synthetic'},
          },
  'error': status == 'failed'
      ? {'code': 'server_error', 'message': 'Synthetic response failure.'}
      : null,
  'incomplete_details': status == 'incomplete'
      ? {'reason': 'max_output_tokens'}
      : null,
  'instructions': null,
  'tools': <Object>[],
  'output': ['completed', 'failed', 'incomplete', 'cancelled'].contains(status)
      ? [
          {
            'type': 'message',
            'id': 'msg_access_fixture',
            'role': 'assistant',
            'status': status == 'completed' ? 'completed' : 'incomplete',
            'content': [
              {
                'type': 'output_text',
                'text': 'Synthetic reply.',
                'annotations': <Object>[],
                'logprobs': <Object>[],
              },
            ],
          },
        ]
      : <Object>[],
  'parallel_tool_calls': false,
  'metadata': {'fixture': 'access-programs'},
  'max_output_tokens': 16,
  'tool_choice': 'auto',
  'temperature': 0.5,
  'top_p': 0.9,
  if (['completed', 'failed', 'incomplete', 'cancelled'].contains(status))
    'usage': _usageJson(),
};

Map<String, dynamic> _usageJson() => {
  'input_tokens': 12,
  'input_tokens_details': {'cached_tokens': 2, 'cache_write_tokens': 1},
  'output_tokens': 3,
  'output_tokens_details': {'reasoning_tokens': 1},
  'total_tokens': 15,
};

Map<String, (Object, bool)> _malformedAccessPrograms() => {
  'outer string': ('daybreak_red', false),
  'outer integer': (7, false),
  'outer boolean': (false, false),
  'outer array': (<Object>[], false),
  'missing cyber': (<String, dynamic>{}, true),
  'cyber null': ({'cyber': null}, true),
  'cyber integer': ({'cyber': 7}, true),
  'cyber boolean': ({'cyber': false}, true),
  'cyber array': ({'cyber': <Object>[]}, true),
  'cyber object': ({'cyber': <String, dynamic>{}}, true),
  'future cyber value': ({'cyber': 'future_program'}, true),
};

Map<String, dynamic> _listJson(List<Map<String, dynamic>> data) => {
  'object': 'list',
  'data': data,
  'has_more': false,
  'first_id': 'resp_access_fixture',
  'last_id': 'resp_access_fixture',
};

http.Response _sseResponse(List<Map<String, dynamic>> events) => http.Response(
  '${events.map((event) => 'event: ${event['type']}\ndata: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);

http.Response _jsonResponse(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);
