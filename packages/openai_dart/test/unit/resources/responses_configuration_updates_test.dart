import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final shapes = <String, Map<String, dynamic>>{
    'omitted reasoning': {'type': 'configuration_update'},
    'empty reasoning': {
      'type': 'configuration_update',
      'reasoning': <String, dynamic>{},
    },
    'nullable input id and effort': {
      'type': 'configuration_update',
      'id': null,
      'reasoning': {'effort': null},
    },
    'high effort with input id': {
      'type': 'configuration_update',
      'id': 'cu_input',
      'reasoning': {'effort': 'high'},
    },
    'low effort': {
      'type': 'configuration_update',
      'reasoning': {'effort': 'low'},
    },
    'beta agent metadata': {
      'type': 'configuration_update',
      'agent': {'agent_name': 'fixture-agent'},
      'reasoning': {'effort': 'high'},
    },
    'unknown reasoning fields stay outside the narrow object': {
      'type': 'configuration_update',
      'reasoning': {
        'effort': 'high',
        'summary': 'auto',
        'context': 'all',
        'mode': 'auto',
      },
    },
  };

  for (final entry in shapes.entries) {
    for (final beta in [false, true]) {
      group('${entry.key} beta=$beta', () {
        final input = <String, dynamic>{
          ...entry.value,
          if (beta) 'agent': {'agent_name': 'fixture-agent'},
        };
        final normalized = _normalizeNullable(input);

        test(
          'Responses create emits only the contextual input shape',
          () async {
            var sends = 0;
            final client = _client(
              MockClient((request) async {
                sends++;
                _expectResponsesProtocol(request, beta: beta);
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': [normalized],
                  'reasoning': {'effort': 'medium'},
                });
                return _jsonResponse(_responseJson());
              }),
            );
            final request = CreateResponseRequest.fromJson({
              'model': 'fixture-model',
              'input': [input],
              'reasoning': const {'effort': 'medium'},
            });
            expect(
              (request.input as ResponseInputItems).items.single,
              isA<ConfigurationUpdateItem>(),
            );
            final response = await client.responses.create(request, beta: beta);
            expect(response.output, isEmpty);
            expect(sends, 1);
          },
        );

        test('SSE accepts input without inventing output or events', () async {
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectResponsesProtocol(request, beta: beta);
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': [normalized],
                'reasoning': {'effort': 'medium'},
                'stream': true,
              });
              return _sseResponse();
            }),
          );
          final events = await client.responses
              .createStream(
                CreateResponseRequest(
                  model: 'fixture-model',
                  input: ResponseInput.items([Item.fromJson(input)]),
                  reasoning: const ReasoningConfig(
                    effort: ReasoningEffort.medium,
                  ),
                ),
                beta: beta,
              )
              .toList();
          expect(events.map((event) => event.type), [
            'response.created',
            'response.completed',
          ]);
          expect(events.first, isA<ResponseCreatedEvent>());
          expect(events.last, isA<ResponseCompletedEvent>());
          expect(events.whereType<UnknownEvent>(), isEmpty);
          expect(events.whereType<OutputItemAddedEvent>(), isEmpty);
          expect(events.whereType<OutputItemDoneEvent>(), isEmpty);
          expect(
            (events.last as ResponseCompletedEvent).response.output,
            isEmpty,
          );
          expect(sends, 1);
        });

        test('list-input parses the required-id returned shape', () async {
          var sends = 0;
          final returned = {...input, 'id': 'cu_returned'};
          final client = _client(
            MockClient((request) async {
              sends++;
              expect(request.method, 'GET');
              expect(
                request.url.path,
                '/v1/responses/resp_fixture/input_items',
              );
              expect(request.url.queryParameters, {
                'limit': '10',
                'order': 'asc',
                if (beta) 'beta': 'true',
              });
              expect(
                request.headers['OpenAI-Beta'],
                beta ? 'responses_multi_agent=v1' : null,
              );
              return _jsonResponse(_listJson([returned]));
            }),
          );
          final result = await client.responses.inputItems.list(
            'resp_fixture',
            limit: 10,
            order: 'asc',
            beta: beta,
          );
          expect(result.data.single, isA<ConfigurationUpdateItemResponse>());
          final item = result.data.single as ConfigurationUpdateItemResponse;
          expect(item.id, 'cu_returned');
          expect(item.toJson(), _normalizeNullable(returned));
          expect(
            item.toConfigurationUpdateItem().toJson(),
            _normalizeNullable(returned),
          );
          expect(sends, 1);
        });
      });
    }

    for (final operation in [
      'conversation-create',
      'create',
      'list',
      'retrieve',
    ]) {
      test('conversation $operation preserves ${entry.key}', () async {
        var sends = 0;
        final input = entry.value;
        final returned = {...input, 'id': 'cu_returned'};
        final client = _client(
          MockClient((request) async {
            sends++;
            if (operation == 'conversation-create') {
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/conversations');
              expect(jsonDecode(request.body), {
                'items': [_normalizeNullable(input)],
              });
              return _jsonResponse({
                'id': 'conv_fixture',
                'object': 'conversation',
                'created_at': 1700000000,
                'metadata': <String, dynamic>{},
              });
            }
            expect(
              request.url.path,
              operation == 'retrieve'
                  ? '/v1/conversations/conv_fixture/items/cu_returned'
                  : '/v1/conversations/conv_fixture/items',
            );
            expect(request.method, operation == 'create' ? 'POST' : 'GET');
            if (operation == 'create') {
              expect(jsonDecode(request.body), {
                'items': [_normalizeNullable(input)],
              });
            }
            if (operation == 'list') {
              expect(request.url.queryParameters, {
                'limit': '10',
                'order': 'asc',
              });
            }
            return _jsonResponse(
              operation == 'retrieve' ? returned : _listJson([returned]),
            );
          }),
        );
        switch (operation) {
          case 'conversation-create':
            final result = await client.conversations.create(
              ConversationCreateRequest.fromJson({
                'items': [input],
              }),
            );
            expect(result.id, 'conv_fixture');
          case 'create':
            final result = await client.conversations.items.create(
              'conv_fixture',
              ItemsCreateRequest.fromJson({
                'items': [input],
              }),
            );
            _expectConversationItem(result.data.single, returned);
          case 'list':
            final result = await client.conversations.items.list(
              'conv_fixture',
              limit: 10,
              order: 'asc',
            );
            _expectConversationItem(result.data.single, returned);
          case 'retrieve':
            final result = await client.conversations.items.retrieve(
              'conv_fixture',
              'cu_returned',
            );
            _expectConversationItem(result, returned);
        }
        expect(sends, 1);
      });
    }
  }

  for (final beta in [false, true]) {
    test(
      'high then low updates keep request effort stable beta=$beta',
      () async {
        var sends = 0;
        const base = CreateResponseRequest(
          model: 'fixture-model',
          input: ResponseInput.text('Start the conversation.'),
          reasoning: ReasoningConfig(effort: ReasoningEffort.medium),
        );
        final originalJson = base.toJson();
        final client = _client(
          MockClient((request) async {
            sends++;
            _expectResponsesProtocol(request, beta: beta);
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['reasoning'], {'effort': 'medium'});
            if (sends == 1) {
              expect(body, originalJson);
            } else {
              final effort = sends == 2 ? 'high' : 'low';
              expect(body, {
                'model': 'fixture-model',
                'input': [
                  {
                    'type': 'configuration_update',
                    'reasoning': {'effort': effort},
                  },
                  {
                    'type': 'message',
                    'role': 'user',
                    'content': [
                      {
                        'type': 'input_text',
                        'text': 'Continue with $effort effort.',
                      },
                    ],
                  },
                ],
                'previous_response_id': 'resp_${sends - 1}',
                'reasoning': {'effort': 'medium'},
              });
            }
            return _jsonResponse(_responseJson(id: 'resp_$sends'));
          }),
        );
        var latest = await client.responses.create(base, beta: beta);
        for (final effort in [ReasoningEffort.high, ReasoningEffort.low]) {
          final updated = base.copyWith(
            previousResponseId: latest.id,
            input: ResponseInput.items([
              ConfigurationUpdateItem(
                reasoning: ConfigurationUpdateReasoning(effort: effort),
              ),
              MessageItem.userText('Continue with ${effort.value} effort.'),
            ]),
          );
          expect(identical(updated.reasoning, base.reasoning), isTrue);
          latest = await client.responses.create(updated, beta: beta);
          // Response metadata reports the stable request-level setting rather
          // than the effective effort changed by the persisted input item.
          expect(latest.reasoning!.effort, ReasoningEffort.medium);
          expect(base.toJson(), originalJson);
          expect(base.previousResponseId, isNull);
          expect(
            base.input,
            const ResponseInput.text('Start the conversation.'),
          );
          expect(base.reasoning!.effort, ReasoningEffort.medium);
        }
        expect(sends, 3);
        expect(latest.id, 'resp_3');
      },
    );

    test(
      'returned configuration can be reused through public Responses beta=$beta',
      () async {
        var sends = 0;
        final returned = <String, dynamic>{
          'type': 'configuration_update',
          'id': 'cu_returned',
          'reasoning': {'effort': 'high'},
          if (beta) 'agent': {'agent_name': 'fixture-agent'},
        };
        final client = _client(
          MockClient((request) async {
            sends++;
            if (sends == 1) {
              expect(
                request.url.path,
                '/v1/responses/resp_fixture/input_items',
              );
              return _jsonResponse(_listJson([returned]));
            }
            _expectResponsesProtocol(request, beta: beta);
            expect(jsonDecode(request.body), {
              'model': 'fixture-model',
              'input': [returned],
              'previous_response_id': 'resp_fixture',
            });
            return _jsonResponse(_responseJson());
          }),
        );
        final listed = await client.responses.inputItems.list(
          'resp_fixture',
          beta: beta,
        );
        final item = listed.data.single as ConfigurationUpdateItemResponse;
        await client.responses.create(
          CreateResponseRequest(
            model: 'fixture-model',
            previousResponseId: 'resp_fixture',
            input: ResponseInput.items([item.toConfigurationUpdateItem()]),
          ),
          beta: beta,
        );
        expect(sends, 2);
      },
    );
  }

  final malformed = <String, Map<String, dynamic>>{
    'missing returned id': {'type': 'configuration_update'},
    'null returned id': {'type': 'configuration_update', 'id': null},
    for (final invalid in <Object>[1, false, <Object>[], <String, dynamic>{}])
      'wrong returned id $invalid': {
        'type': 'configuration_update',
        'id': invalid,
      },
    for (final invalid in <Object?>[null, 1, false, 'high', <Object>[]])
      'nonobject reasoning $invalid': {
        'type': 'configuration_update',
        'id': 'cu_returned',
        'reasoning': invalid,
      },
    for (final invalid in <Object>[1, false, <Object>[], <String, dynamic>{}])
      'nonstring effort $invalid': {
        'type': 'configuration_update',
        'id': 'cu_returned',
        'reasoning': {'effort': invalid},
      },
    for (final invalid in <Object?>[null, 1, 'agent', <Object>[]])
      'nonobject returned agent $invalid': {
        'type': 'configuration_update',
        'id': 'cu_returned',
        'agent': invalid,
      },
    for (final agent in <Map<String, dynamic>>[
      {},
      {'agent_name': null},
      {'agent_name': 1},
    ])
      'malformed returned agent $agent': {
        'type': 'configuration_update',
        'id': 'cu_returned',
        'agent': agent,
      },
  };
  for (final entry in malformed.entries) {
    for (final operation in ['list-input', 'create', 'list', 'retrieve']) {
      test('$operation rejects ${entry.key} contextually', () async {
        var sends = 0;
        final client = _client(
          MockClient((request) async {
            sends++;
            return _jsonResponse(
              operation == 'retrieve' ? entry.value : _listJson([entry.value]),
            );
          }),
        );
        final Future<Object> result = switch (operation) {
          'list-input' => client.responses.inputItems.list('resp_fixture'),
          'create' => client.conversations.items.create(
            'conv_fixture',
            const ItemsCreateRequest(items: [ConfigurationUpdateItem()]),
          ),
          'list' => client.conversations.items.list('conv_fixture'),
          _ => client.conversations.items.retrieve(
            'conv_fixture',
            'cu_returned',
          ),
        };
        await expectLater(
          result,
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'context',
              contains(
                operation == 'list-input'
                    ? 'ConfigurationUpdateItemResponse'
                    : 'ConversationConfigurationUpdateItem',
              ),
            ),
          ),
        );
        expect(sends, 1);
      });
    }
  }

  for (final operation in ['Responses', 'conversation', 'items']) {
    for (final input in malformed.entries.where(
      (entry) =>
          entry.key.startsWith('nonobject reasoning') ||
          entry.key.startsWith('nonstring') ||
          entry.key.startsWith('wrong returned') ||
          (entry.key.contains('returned agent') &&
              entry.value['agent'] != null),
    )) {
      test('$operation request parser rejects ${input.key}', () {
        final item = input.value;
        expect(
          () => switch (operation) {
            'Responses' => CreateResponseRequest.fromJson({
              'model': 'fixture-model',
              'input': [item],
            }),
            'conversation' => ConversationCreateRequest.fromJson({
              'items': [item],
            }),
            _ => ItemsCreateRequest.fromJson({
              'items': [item],
            }),
          },
          throwsA(isA<FormatException>()),
        );
      });
    }
  }

  test('unknown conversation items retain provider tolerance', () async {
    const unknown = <String, dynamic>{
      'type': 'future_configuration',
      'id': 'future_item',
      'reasoning': {'future_option': true},
    };
    final client = _client(MockClient((_) async => _jsonResponse(unknown)));
    final result = await client.conversations.items.retrieve(
      'conv_fixture',
      'future_item',
    );
    expect(result, isA<ConversationUnknownItem>());
    expect(result.toJson(), unknown);
  });

  test(
    'unknown list-input discriminator keeps its existing rejection',
    () async {
      final client = _client(
        MockClient(
          (_) async => _jsonResponse(
            _listJson([
              {'type': 'future_configuration', 'id': 'future_item'},
            ]),
          ),
        ),
      );
      await expectLater(
        client.responses.inputItems.list('resp_fixture'),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('nullable beta input agent is accepted and omitted', () async {
    final client = _client(
      MockClient((request) async {
        _expectResponsesProtocol(request, beta: true);
        expect(jsonDecode(request.body), {
          'model': 'fixture-model',
          'input': [
            {'type': 'configuration_update'},
          ],
        });
        return _jsonResponse(_responseJson());
      }),
    );
    await client.responses.create(
      CreateResponseRequest.fromJson(const {
        'model': 'fixture-model',
        'input': [
          {'type': 'configuration_update', 'agent': null},
        ],
      }),
      beta: true,
    );
  });

  test('list-input retains every existing reasoning effort value', () async {
    final efforts = ReasoningEffort.values
        .where((effort) => effort != ReasoningEffort.unknown)
        .toList();
    final returned = [
      for (final effort in efforts)
        {
          'type': 'configuration_update',
          'id': 'cu_${effort.value}',
          'reasoning': {'effort': effort.value},
        },
    ];
    final client = _client(
      MockClient((_) async => _jsonResponse(_listJson(returned))),
    );
    final result = await client.responses.inputItems.list('resp_fixture');
    expect(
      result.data.cast<ConfigurationUpdateItemResponse>().map(
        (item) => item.reasoning!.effort,
      ),
      efforts,
    );
    expect(result.data.map((item) => item.toJson()).toList(), returned);
  });

  test('unknown reasoning effort keeps existing enum tolerance', () async {
    final client = _client(
      MockClient(
        (_) async => _jsonResponse(
          _listJson([
            {
              'type': 'configuration_update',
              'id': 'cu_returned',
              'reasoning': {'effort': 'future_effort'},
            },
          ]),
        ),
      ),
    );
    final result = await client.responses.inputItems.list('resp_fixture');
    final item = result.data.single as ConfigurationUpdateItemResponse;
    expect(item.reasoning!.effort, ReasoningEffort.unknown);
    expect(item.toJson(), {
      'type': 'configuration_update',
      'id': 'cu_returned',
      'reasoning': {'effort': 'unknown'},
    });
  });
}

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

void _expectResponsesProtocol(http.Request request, {required bool beta}) {
  expect(request.method, 'POST');
  expect(request.url.path, '/v1/responses');
  expect(request.url.queryParameters, beta ? {'beta': 'true'} : isEmpty);
  expect(
    request.headers['OpenAI-Beta'],
    beta ? 'responses_multi_agent=v1' : null,
  );
  expect(request.headers['Authorization'], 'Bearer fixture-key');
}

void _expectConversationItem(
  ConversationItem item,
  Map<String, dynamic> returned,
) {
  expect(item, isA<ConversationConfigurationUpdateItem>());
  final update = item as ConversationConfigurationUpdateItem;
  expect(update.id, 'cu_returned');
  expect(update.toJson(), _normalizeNullable(returned));
  expect(
    update.toConfigurationUpdateItem().toJson(),
    _normalizeNullable(returned),
  );
}

Map<String, dynamic> _normalizeNullable(Map<String, dynamic> item) => {
  'type': item['type'],
  if (item['id'] != null) 'id': item['id'],
  if (item.containsKey('reasoning'))
    'reasoning': {
      if ((item['reasoning'] as Map)['effort'] != null)
        'effort': (item['reasoning'] as Map)['effort'],
    },
  if (item['agent'] != null) 'agent': item['agent'],
};

Map<String, dynamic> _responseJson({
  String id = 'resp_fixture',
  String status = 'completed',
  String effort = 'medium',
}) => {
  'id': id,
  'object': 'response',
  'created_at': 1700000000,
  'status': status,
  'model': 'fixture-model',
  'output': <Object>[],
  'reasoning': {'effort': effort},
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <Object>[],
  'parallel_tool_calls': false,
  'metadata': <String, dynamic>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};

Map<String, dynamic> _listJson(List<Map<String, dynamic>> data) => {
  'object': 'list',
  'data': data,
  'has_more': false,
  'first_id': data.isEmpty ? null : data.first['id'],
  'last_id': data.isEmpty ? null : data.last['id'],
};

http.Response _jsonResponse(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);

http.Response _sseResponse() {
  final events = [
    {
      'type': 'response.created',
      'sequence_number': 0,
      'response': _responseJson(status: 'in_progress'),
    },
    {
      'type': 'response.completed',
      'sequence_number': 1,
      'response': _responseJson(),
    },
  ];
  return http.Response(
    '${events.map((event) => 'event: ${event['type']}\ndata: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
    200,
    headers: {'content-type': 'text/event-stream'},
  );
}
