import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final beta in [false, true]) {
    for (final accumulated in [false, true]) {
      final operation = accumulated ? 'accumulated SSE' : 'SSE';
      test('$operation preserves compaction progress beta=$beta', () async {
        final rawEvents = _events(beta: beta);
        var sends = 0;
        final client = _client(
          MockClient((request) async {
            sends++;
            _expectRequest(request, beta: beta, streaming: true);
            return _sseResponse(rawEvents);
          }),
        );

        if (accumulated) {
          Response? beforeProgress;
          final received = <ResponseStreamEvent>[];
          await for (final accumulator
              in client.responses.createStreamWithAccumulator(
                _request(beta: beta),
                beta: beta,
              )) {
            final event = accumulator.latestEvent!;
            received.add(event);
            if (event is OutputItemAddedEvent && event.outputIndex == 2) {
              beforeProgress = accumulator.response;
              _expectInProgress(accumulator);
            }
            if (event is ResponseCompactionCompactingEvent) {
              _expectProgress(event, beta: beta);
              expect(accumulator.response, same(beforeProgress));
              _expectInProgress(accumulator);
            }
            if (event is ResponseCompletedEvent) {
              _expectCompleted(accumulator.response!, beta: beta);
              expect(accumulator.status, ResponseStatus.completed);
              expect(accumulator.isComplete, isTrue);
              expect(accumulator.isSuccessful, isTrue);
              expect(accumulator.text, 'Synthetic reply.');
              expect(accumulator.reasoning, 'Synthetic reasoning.');
              expect(accumulator.usage?.toJson(), _usageJson());
            }
          }
          expect(
            received.map((event) => event.type),
            rawEvents.map((event) => event['type']),
          );
        } else {
          final events = await client.responses
              .createStream(_request(beta: beta), beta: beta)
              .toList();
          expect(
            events.map((event) => event.type),
            rawEvents.map((event) => event['type']),
          );
          expect(events.whereType<UnknownEvent>(), isEmpty);
          final progress = events
              .whereType<ResponseCompactionCompactingEvent>()
              .single;
          _expectProgress(progress, beta: beta);
          final position = events.indexOf(progress);
          final added = events[position - 1] as OutputItemAddedEvent;
          final done = events[position + 1] as OutputItemDoneEvent;
          expect(added.outputIndex, progress.outputIndex);
          expect(done.outputIndex, progress.outputIndex);
          expect((added.item as CompactionOutputItem).id, progress.itemId);
          expect(
            (done.item as CompactionOutputItem).toJson(),
            _compactionItem(beta: beta),
          );
          _expectCompleted(
            (events.last as ResponseCompletedEvent).response,
            beta: beta,
          );
        }
        expect(sends, 1);
      });

      test(
        '$operation accepts absent optional beta agent beta=$beta',
        () async {
          final progress = _progress(beta: beta)..remove('agent');
          final client = _client(
            MockClient((request) async {
              _expectRequest(request, beta: beta, streaming: true);
              return _sseResponse([
                progress,
                {
                  'type': 'response.completed',
                  'sequence_number': 10,
                  'response': _responseJson(beta: beta),
                },
              ]);
            }),
          );
          if (accumulated) {
            var observed = false;
            await for (final state
                in client.responses.createStreamWithAccumulator(
                  _request(beta: beta),
                  beta: beta,
                )) {
              if (state.latestEvent is ResponseCompactionCompactingEvent) {
                observed = true;
                final event =
                    state.latestEvent! as ResponseCompactionCompactingEvent;
                expect(event.agent, isNull);
                expect(event.toJson(), progress);
                expect(state.response, isNull);
                expect(state.status, ResponseStatus.queued);
                expect(state.isComplete, isFalse);
              }
            }
            expect(observed, isTrue);
          } else {
            final events = await client.responses
                .createStream(_request(beta: beta), beta: beta)
                .toList();
            final event = events.first as ResponseCompactionCompactingEvent;
            expect(event.agent, isNull);
            expect(event.toJson(), progress);
          }
        },
      );

      test('$operation retains future compaction event beta=$beta', () async {
        final future = <String, dynamic>{
          'type': 'response.compaction.future',
          'sequence_number': 12,
          'item_id': 'cmp_future',
          'future': {
            'nested': [
              false,
              null,
              {'value': 7},
            ],
          },
          if (beta) 'agent': {'agent_name': 'compactor'},
        };
        // The existing SSE parser preserves its event-name metadata as well.
        final futureFromSse = {...future, '_event': future['type']};
        final rawEvents = [
          {
            'type': 'response.in_progress',
            'sequence_number': 11,
            'response': _responseJson(beta: beta, completed: false),
          },
          future,
          {
            'type': 'response.completed',
            'sequence_number': 13,
            'response': _responseJson(beta: beta),
          },
        ];
        final client = _client(
          MockClient((request) async {
            _expectRequest(request, beta: beta, streaming: true);
            return _sseResponse(rawEvents);
          }),
        );
        if (accumulated) {
          Response? previous;
          var observedFuture = false;
          var completed = false;
          await for (final state
              in client.responses.createStreamWithAccumulator(
                _request(beta: beta),
                beta: beta,
              )) {
            if (state.latestEvent is ResponseInProgressEvent) {
              previous = state.response;
            } else if (state.latestEvent is UnknownEvent) {
              observedFuture = true;
              final event = state.latestEvent! as UnknownEvent;
              expect(event.rawJson, futureFromSse);
              expect(event.toJson(), futureFromSse);
              expect(event.sequenceNumber, 12);
              expect(state.response, same(previous));
              expect(state.status, ResponseStatus.inProgress);
              expect(state.isComplete, isFalse);
              expect(state.text, isEmpty);
              expect(state.reasoning, isEmpty);
            } else if (state.latestEvent is ResponseCompletedEvent) {
              completed = true;
              _expectCompleted(state.response!, beta: beta);
            }
          }
          expect(observedFuture, isTrue);
          expect(completed, isTrue);
        } else {
          final events = await client.responses
              .createStream(_request(beta: beta), beta: beta)
              .toList();
          final unknown = events[1] as UnknownEvent;
          expect(unknown.type, future['type']);
          expect(unknown.sequenceNumber, 12);
          expect(unknown.rawJson, futureFromSse);
          expect(unknown.toJson(), futureFromSse);
          _expectCompleted(
            (events.last as ResponseCompletedEvent).response,
            beta: beta,
          );
        }
      });

      for (final entry in _malformedCases().entries) {
        test('$operation rejects ${entry.key} beta=$beta', () async {
          final (field, value, omitted) = entry.value;
          final progress = _progress(beta: beta);
          if (omitted) {
            progress.remove(field);
          } else {
            progress[field] = value;
          }
          final client = _client(
            MockClient((request) async {
              _expectRequest(request, beta: beta, streaming: true);
              return _sseResponse([
                {
                  'type': 'response.created',
                  'sequence_number': 0,
                  'response': _responseJson(beta: beta, completed: false),
                },
                progress,
                {
                  'type': 'response.completed',
                  'sequence_number': 10,
                  'response': _responseJson(beta: beta),
                },
              ]);
            }),
          );
          final expected = throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'contextual field',
              contains('ResponseCompactionCompactingEvent.$field'),
            ),
          );
          if (accumulated) {
            await expectLater(
              client.responses
                  .createStreamWithAccumulator(_request(beta: beta), beta: beta)
                  .toList(),
              expected,
            );
          } else {
            await expectLater(
              client.responses
                  .createStream(_request(beta: beta), beta: beta)
                  .toList(),
              expected,
            );
          }
        });
      }
    }

    test(
      'compact REST keeps encrypted item and writable replay beta=$beta',
      () async {
        final compactedJson = <String, dynamic>{
          'id': 'compact_resource',
          'object': 'response.compaction',
          'created_at': 1700000000,
          'output': [
            {
              'type': 'message',
              'id': 'input_message',
              'role': 'user',
              'status': 'completed',
              'content': [
                {'type': 'input_text', 'text': 'Synthetic history.'},
              ],
              if (beta) 'agent': {'agent_name': 'compactor'},
            },
            _compactionItem(beta: beta),
          ],
          'usage': _usageJson(),
        };
        var sends = 0;
        final history = _history(beta: beta);
        final client = _client(
          MockClient((request) async {
            sends++;
            _expectProtocol(request, beta: beta);
            expect(request.method, 'POST');
            expect(
              request.url.queryParameters,
              beta ? {'beta': 'true'} : isEmpty,
            );
            if (sends == 1) {
              expect(request.url.path, '/v1/responses/compact');
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': history,
                'previous_response_id': 'previous_fixture',
                'instructions': 'Preserve the synthetic state.',
              });
              return _jsonResponse(compactedJson);
            }
            expect(request.url.path, '/v1/responses');
            expect(jsonDecode(request.body), {
              'model': 'fixture-model',
              'input': compactedJson['output'],
              'context_management': [
                {'type': 'compaction', 'compact_threshold': 1000},
              ],
            });
            return _jsonResponse(_responseJson(beta: beta));
          }),
        );
        final compacted = await client.responses.compact(
          CompactResponseRequest(
            model: 'fixture-model',
            input: ResponseInput.fromOutputItems(history),
            previousResponseId: 'previous_fixture',
            instructions: 'Preserve the synthetic state.',
          ),
          beta: beta,
        );
        expect(compacted, isA<ResponseCompaction>());
        expect(compacted.toJson(), compactedJson);
        final encrypted = compacted.output.last as CompactionOutputItem;
        expect(encrypted.toJson(), _compactionItem(beta: beta));
        expect(encrypted.toString(), isNot(contains(_ciphertext)));
        expect(compacted.toString(), isNot(contains(_ciphertext)));
        expect(compacted.toInput().toJson(), compactedJson['output']);
        final continued = await client.responses.create(
          CreateResponseRequest(
            model: 'fixture-model',
            input: compacted.toInput(),
            contextManagement: const [
              ContextManagement.compaction(compactThreshold: 1000),
            ],
          ),
          beta: beta,
        );
        _expectCompleted(continued, beta: beta);
        expect(sends, 2);
      },
    );

    for (final threshold in [null, 1000]) {
      test('typed trigger and context management remain available '
          'threshold=$threshold beta=$beta', () async {
        final trigger = CompactionTriggerItem(
          agent: beta ? const AgentTag(agentName: 'compactor') : null,
        );
        final context = ContextManagement.compaction(
          compactThreshold: threshold,
        );
        final client = _client(
          MockClient((request) async {
            _expectProtocol(request, beta: beta);
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/responses');
            expect(
              request.url.queryParameters,
              beta ? {'beta': 'true'} : isEmpty,
            );
            expect(jsonDecode(request.body), {
              'model': 'fixture-model',
              'input': [trigger.toJson()],
              'context_management': [context.toJson()],
              'stream': true,
            });
            return _sseResponse([
              _progress(beta: beta),
              {
                'type': 'response.completed',
                'sequence_number': 10,
                'response': _responseJson(beta: beta),
              },
            ]);
          }),
        );
        final request = CreateResponseRequest.fromJson({
          'model': 'fixture-model',
          'input': [trigger.toJson()],
          'context_management': [
            {'type': 'compaction', 'compact_threshold': threshold},
          ],
        });
        expect((request.input as ResponseInputItems).items.single, trigger);
        expect(request.contextManagement!.single, context);
        final events = await client.responses
            .createStream(request, beta: beta)
            .toList();
        _expectProgress(
          events.first as ResponseCompactionCompactingEvent,
          beta: beta,
        );
      });
    }
  }
}

const _ciphertext = 'synthetic-encrypted-compaction-payload';

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

void _expectProtocol(http.Request request, {required bool beta}) {
  expect(request.headers['Authorization'], 'Bearer fixture-key');
  expect(request.headers['Content-Type'], 'application/json');
  expect(
    request.headers['OpenAI-Beta'],
    beta ? 'responses_multi_agent=v1' : null,
  );
}

void _expectRequest(
  http.Request request, {
  required bool beta,
  required bool streaming,
}) {
  _expectProtocol(request, beta: beta);
  expect(request.method, 'POST');
  expect(request.url.path, '/v1/responses');
  expect(request.url.queryParameters, beta ? {'beta': 'true'} : isEmpty);
  expect(jsonDecode(request.body), {
    'model': 'fixture-model',
    'input': _history(beta: beta),
    'context_management': [
      {'type': 'compaction', 'compact_threshold': 1000},
    ],
    if (streaming) 'stream': true,
  });
}

CreateResponseRequest _request({required bool beta}) => CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.fromOutputItems(_history(beta: beta)),
  contextManagement: const [
    ContextManagement.compaction(compactThreshold: 1000),
  ],
);

List<Map<String, dynamic>> _history({required bool beta}) => [
  {
    'type': 'compaction',
    'id': 'cmp_previous',
    'encrypted_content': 'synthetic-prior-encrypted-payload',
    if (beta) 'agent': {'agent_name': 'compactor'},
  },
  {
    'type': 'compaction_trigger',
    'id': 'trigger_fixture',
    if (beta) 'agent': {'agent_name': 'compactor'},
  },
];

Map<String, dynamic> _compactionItem({required bool beta}) => {
  'type': 'compaction',
  'id': 'cmp_fixture',
  'encrypted_content': _ciphertext,
  'created_by': 'fixture_creator',
  if (beta) 'agent': {'agent_name': 'compactor'},
};

Map<String, dynamic> _progress({required bool beta}) => {
  'type': 'response.compaction.compacting',
  'sequence_number': 9,
  'output_index': 2,
  'item_id': 'cmp_fixture',
  if (beta) 'agent': {'agent_name': 'compactor'},
};

void _expectProgress(
  ResponseCompactionCompactingEvent event, {
  required bool beta,
}) {
  expect(event.toJson(), _progress(beta: beta));
  expect(event.sequenceNumber, 9);
  expect(event.outputIndex, 2);
  expect(event.itemId, 'cmp_fixture');
  expect(event.agent?.agentName, beta ? 'compactor' : null);
  expect(event.isFinal, isFalse);
  expect(event.finalResponse, isNull);
  expect(event.textDelta, isNull);
  expect(event.toJson().containsKey('summary'), isFalse);
  expect(event.toJson().containsKey('encrypted_content'), isFalse);
  expect(event.toString(), isNot(contains(_ciphertext)));
}

void _expectInProgress(ResponseStreamAccumulator state) {
  expect(state.status, ResponseStatus.inProgress);
  expect(state.isComplete, isFalse);
  expect(state.isSuccessful, isFalse);
  expect(state.isFailed, isFalse);
  expect(state.text, 'Synthetic reply.');
  expect(state.reasoning, 'Synthetic reasoning.');
  expect(state.functionArguments, isEmpty);
  expect(state.usage, isNull);
  expect(state.response!.output, isEmpty);
}

void _expectCompleted(Response response, {required bool beta}) {
  expect(response.id, 'resp_compaction');
  expect(response.status, ResponseStatus.completed);
  expect(response.output, hasLength(3));
  expect(response.outputText, 'Synthetic reply.');
  final compaction = response.output.last as CompactionOutputItem;
  expect(compaction.toJson(), _compactionItem(beta: beta));
  expect(compaction.encryptedContent, _ciphertext);
  expect(compaction.createdBy, 'fixture_creator');
  expect(compaction.agent?.agentName, beta ? 'compactor' : null);
  expect(compaction.toString(), isNot(contains(_ciphertext)));
  expect(response.toString(), isNot(contains(_ciphertext)));
}

Map<String, dynamic> _usageJson() => {
  'input_tokens': 12,
  'input_tokens_details': {'cached_tokens': 2, 'cache_write_tokens': 1},
  'output_tokens': 3,
  'output_tokens_details': {'reasoning_tokens': 1},
  'total_tokens': 15,
};

Map<String, dynamic> _responseJson({
  required bool beta,
  bool completed = true,
}) => {
  // Include every required member of both the canonical GA and beta Response.
  'id': 'resp_compaction',
  'object': 'response',
  'created_at': 1700000000,
  'status': completed ? 'completed' : 'in_progress',
  'model': 'fixture-model',
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <Object>[],
  'output': completed ? _output(beta: beta) : <Object>[],
  'parallel_tool_calls': false,
  'metadata': <String, String>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
  if (completed) 'usage': _usageJson(),
};

List<Map<String, dynamic>> _output({required bool beta}) => [
  {
    'type': 'message',
    'id': 'msg_fixture',
    'role': 'assistant',
    'status': 'completed',
    'content': [
      {
        'type': 'output_text',
        'text': 'Synthetic reply.',
        'annotations': <Object>[],
        'logprobs': <Object>[],
      },
    ],
    if (beta) 'agent': {'agent_name': 'compactor'},
  },
  {
    'type': 'reasoning',
    'id': 'reasoning_fixture',
    'status': 'completed',
    'summary': <Object>[],
    'content': [
      {'type': 'reasoning_text', 'text': 'Synthetic reasoning.'},
    ],
    if (beta) 'agent': {'agent_name': 'compactor'},
  },
  _compactionItem(beta: beta),
];

List<Map<String, dynamic>> _events({required bool beta}) {
  final output = _output(beta: beta);
  return [
    {
      'type': 'response.created',
      'sequence_number': 0,
      'response': _responseJson(beta: beta, completed: false),
    },
    {
      'type': 'response.in_progress',
      'sequence_number': 1,
      'response': _responseJson(beta: beta, completed: false),
    },
    {
      'type': 'response.output_item.added',
      'sequence_number': 2,
      'output_index': 0,
      'item': {...output[0], 'content': <Object>[]},
    },
    {
      'type': 'response.output_text.delta',
      'sequence_number': 3,
      'output_index': 0,
      'item_id': 'msg_fixture',
      'content_index': 0,
      'delta': 'Synthetic reply.',
      'logprobs': <Object>[],
    },
    {
      'type': 'response.output_item.done',
      'sequence_number': 4,
      'output_index': 0,
      'item': output[0],
    },
    {
      'type': 'response.output_item.added',
      'sequence_number': 5,
      'output_index': 1,
      'item': {...output[1], 'content': <Object>[]},
    },
    {
      'type': 'response.reasoning_text.delta',
      'sequence_number': 6,
      'output_index': 1,
      'item_id': 'reasoning_fixture',
      'content_index': 0,
      'delta': 'Synthetic reasoning.',
    },
    {
      'type': 'response.output_item.done',
      'sequence_number': 7,
      'output_index': 1,
      'item': output[1],
    },
    {
      'type': 'response.output_item.added',
      'sequence_number': 8,
      'output_index': 2,
      'item': {...output[2], 'encrypted_content': ''},
    },
    _progress(beta: beta),
    {
      'type': 'response.output_item.done',
      'sequence_number': 10,
      'output_index': 2,
      'item': output[2],
    },
    {
      'type': 'response.completed',
      'sequence_number': 11,
      'response': _responseJson(beta: beta),
    },
  ];
}

Map<String, (String, Object?, bool)> _malformedCases() => {
  for (final field in ['sequence_number', 'output_index', 'item_id']) ...{
    '$field missing': (field, null, true),
    '$field null': (field, null, false),
    '$field boolean': (field, false, false),
    '$field array': (field, <Object>[], false),
    '$field object': (field, <String, dynamic>{}, false),
  },
  'sequence_number string': ('sequence_number', '9', false),
  'sequence_number fractional': ('sequence_number', 9.5, false),
  'output_index string': ('output_index', '2', false),
  'output_index fractional': ('output_index', 2.5, false),
  'item_id integer': ('item_id', 9, false),
  'agent null': ('agent', null, false),
  'agent string': ('agent', 'compactor', false),
  'agent boolean': ('agent', false, false),
  'agent integer': ('agent', 9, false),
  'agent array': ('agent', <Object>[], false),
  'agent_name missing': ('agent', <String, dynamic>{}, false),
  'agent_name null': ('agent', {'agent_name': null}, false),
  'agent_name integer': ('agent', {'agent_name': 9}, false),
  'agent_name boolean': ('agent', {'agent_name': false}, false),
  'agent_name array': ('agent', {'agent_name': <Object>[]}, false),
  'agent_name object': ('agent', {'agent_name': <String, dynamic>{}}, false),
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
