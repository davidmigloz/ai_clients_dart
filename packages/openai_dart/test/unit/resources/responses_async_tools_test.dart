import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final flag in <bool?>[null, false, true]) {
    for (final beta in [false, true]) {
      group('async=${flag ?? 'absent'} beta=$beta', () {
        test(
          'create sends nested definitions and parses direct calls',
          () async {
            var sends = 0;
            final input = _inputJson(flag, beta: beta);
            final output = _outputJson(flag, beta: beta);
            final client = _client(
              MockClient((request) async {
                sends++;
                _expectResponsesProtocol(request, beta: beta);
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': input,
                  'tools': _toolsJson(flag),
                  'parallel_tool_calls': false,
                });
                return _jsonResponse(_responseJson(output));
              }),
            );
            final response = await client.responses.create(
              CreateResponseRequest(
                model: 'fixture-model',
                input: ResponseInput.items(input.map(Item.fromJson).toList()),
                tools: _tools(flag),
                parallelToolCalls: false,
              ),
              beta: beta,
            );
            expect(
              response.output.map((item) => item.toJson()).toList(),
              output,
            );
            expect(
              (response.output[0] as FunctionCallOutputItemResponse).async,
              flag,
            );
            expect((response.output[1] as CustomToolCallItem).async, flag);
            expect(sends, 1);
          },
        );

        test(
          'SSE item and lifecycle events retain calls and nested tools',
          () async {
            var sends = 0;
            final output = _outputJson(flag, beta: beta);
            final client = _client(
              MockClient((request) async {
                sends++;
                _expectResponsesProtocol(request, beta: beta);
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': 'Run the fixture tools.',
                  'tools': _toolsJson(flag),
                  'parallel_tool_calls': false,
                  'stream': true,
                });
                return _sseResponse(_events(output, beta: beta));
              }),
            );
            final events = await client.responses
                .createStream(
                  CreateResponseRequest(
                    model: 'fixture-model',
                    input: const ResponseInput.text('Run the fixture tools.'),
                    tools: _tools(flag),
                    parallelToolCalls: false,
                  ),
                  beta: beta,
                )
                .toList();
            final added = events.whereType<OutputItemAddedEvent>().toList();
            final done = events.whereType<OutputItemDoneEvent>().toList();
            expect(added, hasLength(output.length));
            expect(done, hasLength(output.length));
            expect(
              added.map((event) => event.item.toJson()).toList(),
              _addedJson(output),
            );
            expect(done.map((event) => event.item.toJson()).toList(), output);
            final completed = events.last as ResponseCompletedEvent;
            expect(
              completed.response.output.map((item) => item.toJson()).toList(),
              output,
            );
            expect(events.whereType<UnknownEvent>(), isEmpty);
            expect(
              events.map((event) => event.type),
              isNot(contains('response.async')),
            );
            expect(sends, 1);
          },
        );

        test('public accumulator final response retains async calls', () async {
          var sends = 0;
          final output = _outputJson(flag, beta: beta);
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectResponsesProtocol(request, beta: beta);
              return _sseResponse(_events(output, beta: beta));
            }),
          );
          final snapshots = await client.responses
              .createStreamWithAccumulator(
                const CreateResponseRequest(
                  model: 'fixture-model',
                  input: ResponseInput.text('Run the fixture tools.'),
                ),
                beta: beta,
              )
              .toList();
          expect(snapshots.last.isSuccessful, isTrue);
          expect(snapshots.last.responseId, 'resp_latest');
          expect(
            snapshots.last.response!.output
                .map((item) => item.toJson())
                .toList(),
            output,
          );
          expect(sends, 1);
        });

        test(
          'list-input parses calls, deferred and discovered definitions',
          () async {
            var sends = 0;
            final input = _inputJson(flag, beta: beta);
            final client = _client(
              MockClient((request) async {
                sends++;
                expect(request.method, 'GET');
                expect(
                  request.url.path,
                  '/v1/responses/resp_latest/input_items',
                );
                expect(request.url.queryParameters, {
                  'limit': '20',
                  'order': 'asc',
                  if (beta) 'beta': 'true',
                });
                expect(
                  request.headers['OpenAI-Beta'],
                  beta ? 'responses_multi_agent=v1' : null,
                );
                return _jsonResponse(_listJson(input));
              }),
            );
            final result = await client.responses.inputItems.list(
              'resp_latest',
              limit: 20,
              order: 'asc',
              beta: beta,
            );
            expect(result.data[0], isA<FunctionCallItem>());
            expect(result.data[1], isA<CustomToolCallInputItem>());
            expect(result.data.map((item) => item.toJson()).toList(), input);
            expect(sends, 1);
          },
        );

        test(
          'replay returns original call IDs against the latest response',
          () async {
            var sends = 0;
            final output = _outputJson(flag, beta: beta);
            final client = _client(
              MockClient((request) async {
                sends++;
                _expectResponsesProtocol(request, beta: beta);
                if (sends == 1) {
                  return _jsonResponse(_responseJson(output));
                }
                final expectedCalls = _callJson(flag, beta: beta);
                expectedCalls[0]['status'] = 'completed';
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': [
                    ...expectedCalls,
                    {
                      'type': 'function_call_output',
                      'call_id': 'call_function',
                      'output': '{"answer":42}',
                    },
                    {
                      'type': 'custom_tool_call_output',
                      'call_id': 'call_custom',
                      'output': 'saved custom result',
                    },
                  ],
                  'previous_response_id': 'resp_latest',
                });
                return _jsonResponse(_responseJson([]));
              }),
            );
            final response = await client.responses.create(
              const CreateResponseRequest(
                model: 'fixture-model',
                input: ResponseInput.text('Start.'),
              ),
              beta: beta,
            );
            final function =
                response.output[0] as FunctionCallOutputItemResponse;
            final custom = response.output[1] as CustomToolCallItem;
            await client.responses.create(
              CreateResponseRequest(
                model: 'fixture-model',
                previousResponseId: response.id,
                input: ResponseInput.items([
                  function.toFunctionCallItem(),
                  custom.toCustomToolCallInputItem(),
                  FunctionCallOutputItem.string(
                    callId: function.callId,
                    output: '{"answer":42}',
                  ),
                  CustomToolCallOutputInputItem.string(
                    callId: custom.callId,
                    output: 'saved custom result',
                  ),
                ]),
              ),
              beta: beta,
            );
            expect(sends, 2);
          },
        );
      });
    }

    for (final operation in [
      'conversation-create',
      'create',
      'list',
      'retrieve',
      'retrieve-custom',
    ]) {
      test(
        'conversation $operation retains async=${flag ?? 'absent'} calls',
        () async {
          var sends = 0;
          final calls = _callJson(flag, beta: true);
          final returned = [
            for (final call in calls)
              {...call, 'status': 'completed', 'created_by': 'fixture-actor'},
          ];
          final client = _client(
            MockClient((request) async {
              sends++;
              if (operation == 'conversation-create') {
                expect(request.method, 'POST');
                expect(request.url.path, '/v1/conversations');
                expect(jsonDecode(request.body), {'items': calls});
                return _jsonResponse({
                  'id': 'conv_fixture',
                  'object': 'conversation',
                  'created_at': 1700000000,
                  'metadata': <String, dynamic>{},
                });
              }
              final retrieve = operation.startsWith('retrieve');
              final itemId = operation == 'retrieve-custom'
                  ? 'ct_fixture'
                  : 'fc_fixture';
              final expectedPath = retrieve
                  ? '/v1/conversations/conv_fixture/items/$itemId'
                  : '/v1/conversations/conv_fixture/items';
              expect(request.url.path, expectedPath);
              expect(request.method, operation == 'create' ? 'POST' : 'GET');
              if (operation == 'create') {
                expect(jsonDecode(request.body), {'items': calls});
              }
              return _jsonResponse(
                retrieve
                    ? returned[operation == 'retrieve-custom' ? 1 : 0]
                    : _listJson(returned),
              );
            }),
          );
          switch (operation) {
            case 'conversation-create':
              final result = await client.conversations.create(
                ConversationCreateRequest(
                  items: calls.map(Item.fromJson).toList(),
                ),
              );
              expect(result.id, 'conv_fixture');
            case 'create':
              final result = await client.conversations.items.create(
                'conv_fixture',
                ItemsCreateRequest(items: calls.map(Item.fromJson).toList()),
              );
              expect(
                result.data.map((item) => item.toJson()).toList(),
                returned,
              );
            case 'list':
              final result = await client.conversations.items.list(
                'conv_fixture',
              );
              expect(
                result.data.map((item) => item.toJson()).toList(),
                returned,
              );
            case 'retrieve':
              final result = await client.conversations.items.retrieve(
                'conv_fixture',
                'fc_fixture',
              );
              expect(result, isA<ConversationFunctionCallItem>());
              expect(result.toJson(), returned[0]);
            case 'retrieve-custom':
              final result = await client.conversations.items.retrieve(
                'conv_fixture',
                'ct_fixture',
              );
              expect(result, isA<ConversationCustomToolCallItem>());
              expect(result.toJson(), returned[1]);
          }
          expect(sends, 1);
        },
      );
    }
  }

  for (final invalid in <Object?>[
    null,
    'true',
    1,
    <Object>[],
    <String, dynamic>{},
  ]) {
    for (final type in ['function_call', 'custom_tool_call']) {
      for (final operation in [
        'create',
        'stream',
        'list-input',
        'conversation',
      ]) {
        test(
          '$operation rejects $type async=$invalid at the public boundary',
          () async {
            var sends = 0;
            final calls = _callJson(true, beta: false);
            final call = {
              ...calls[type == 'function_call' ? 0 : 1],
              'status': 'completed',
              'async': invalid,
            };
            final client = _client(
              MockClient((request) async {
                sends++;
                if (operation == 'stream') {
                  return _sseResponse([
                    {
                      'type': 'response.output_item.added',
                      'output_index': 0,
                      'sequence_number': 1,
                      'item': call,
                    },
                  ]);
                }
                if (operation == 'create') {
                  return _jsonResponse(_responseJson([call]));
                }
                if (operation == 'list-input') {
                  return _jsonResponse(_listJson([call]));
                }
                return _jsonResponse(call);
              }),
            );
            const request = CreateResponseRequest(
              model: 'fixture-model',
              input: ResponseInput.text('Start.'),
            );
            final Future<Object> result = switch (operation) {
              'create' => client.responses.create(request),
              'stream' => client.responses.createStream(request).toList(),
              'list-input' => client.responses.inputItems.list('resp_latest'),
              _ => client.conversations.items.retrieve(
                'conv_fixture',
                'fc_fixture',
              ),
            };
            await expectLater(result, throwsA(isA<FormatException>()));
            expect(sends, 1);
          },
        );
      }
    }
    for (final type in ['function', 'custom']) {
      test('request parser rejects nested $type async=$invalid', () {
        final tools = _toolsJson(true);
        final namespace = tools[2];
        final nested = namespace['tools'] as List<Map<String, dynamic>>;
        nested[type == 'function' ? 0 : 1]['async'] = invalid;
        expect(
          () => CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': [
              {
                'type': 'tool_search_output',
                'call_id': 'call_search',
                'execution': 'client',
                'tools': [namespace],
              },
            ],
          }),
          throwsA(isA<FormatException>()),
        );
      });
    }
  }
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

const _parameters = <String, dynamic>{
  'type': 'object',
  'properties': <String, dynamic>{
    'query': <String, dynamic>{'type': 'string'},
  },
  'required': ['query'],
  'additionalProperties': false,
};
const _outputSchema = <String, dynamic>{
  'type': 'object',
  'properties': <String, dynamic>{
    'answer': <String, dynamic>{'type': 'integer'},
  },
};

List<ResponseTool> _tools(bool? flag) {
  final function = ResponseTool.function(
    name: 'lookup',
    description: 'Lookup fixture data.',
    parameters: _parameters,
    strict: true,
    deferLoading: true,
    allowedCallers: const [CallableToolAllowedCaller.direct],
    outputSchema: _outputSchema,
    async: flag,
  );
  final custom = ResponseTool.custom(
    name: 'render',
    description: 'Render fixture data.',
    format: const {'type': 'text'},
    deferLoading: false,
    allowedCallers: const [CallableToolAllowedCaller.direct],
    async: flag,
  );
  return [
    function,
    custom,
    ResponseTool.namespace(
      name: 'fixture',
      description: 'Fixture namespace.',
      tools: [function, custom],
    ),
  ];
}

List<Map<String, dynamic>> _toolsJson(bool? flag) {
  final function = <String, dynamic>{
    'type': 'function',
    'name': 'lookup',
    'description': 'Lookup fixture data.',
    'parameters': _parameters,
    'strict': true,
    'defer_loading': true,
    'allowed_callers': ['direct'],
    'output_schema': _outputSchema,
    'async': ?flag,
  };
  final custom = <String, dynamic>{
    'type': 'custom',
    'name': 'render',
    'description': 'Render fixture data.',
    'format': {'type': 'text'},
    'defer_loading': false,
    'allowed_callers': ['direct'],
    'async': ?flag,
  };
  return [
    function,
    custom,
    {
      'type': 'namespace',
      'name': 'fixture',
      'description': 'Fixture namespace.',
      'tools': [function, custom],
    },
  ];
}

List<Map<String, dynamic>> _callJson(bool? flag, {required bool beta}) => [
  {
    'type': 'function_call',
    'id': 'fc_fixture',
    if (beta) 'agent': {'agent_name': 'researcher'},
    'call_id': 'call_function',
    'name': 'lookup',
    'arguments': '{"query":"fixture"}',
    'namespace': 'fixture',
    'caller': {'type': 'direct'},
    'async': ?flag,
  },
  {
    'type': 'custom_tool_call',
    'id': 'ct_fixture',
    if (beta) 'agent': {'agent_name': 'researcher'},
    'call_id': 'call_custom',
    'name': 'render',
    'input': 'fixture input',
    'namespace': 'fixture',
    'caller': {'type': 'direct'},
    'async': ?flag,
  },
];

List<Map<String, dynamic>> _inputJson(bool? flag, {required bool beta}) => [
  ..._callJson(flag, beta: beta),
  {
    'type': 'additional_tools',
    'id': 'at_fixture',
    if (beta) 'agent': {'agent_name': 'researcher'},
    'role': 'developer',
    'tools': _toolsJson(flag),
  },
  {
    'type': 'tool_search_output',
    'id': 'ts_fixture',
    if (beta) 'agent': {'agent_name': 'researcher'},
    'call_id': 'call_search',
    'execution': 'client',
    'status': 'completed',
    'tools': [_toolsJson(flag)[2]],
  },
];

List<Map<String, dynamic>> _outputJson(bool? flag, {required bool beta}) => [
  for (final call in _callJson(flag, beta: beta))
    {...call, 'status': 'completed', 'created_by': 'fixture-actor'},
  ..._inputJson(flag, beta: beta).skip(2),
];

Map<String, dynamic> _responseJson(
  List<Map<String, dynamic>> output, {
  String status = 'completed',
}) => {
  'id': 'resp_latest',
  'object': 'response',
  'created_at': 1700000000,
  'status': status,
  'model': 'fixture-model',
  'output': output,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'metadata': <String, dynamic>{},
  'parallel_tool_calls': false,
  'temperature': 1.0,
  'top_p': 1.0,
  'tool_choice': 'auto',
  'tools': <Object>[],
  'access_programs': null,
  'usage': {
    'input_tokens': 8,
    'input_tokens_details': {'cached_tokens': 0},
    'output_tokens': 2,
    'output_tokens_details': {'reasoning_tokens': 0},
    'total_tokens': 10,
  },
};

Map<String, dynamic> _listJson(List<Map<String, dynamic>> data) => {
  'object': 'list',
  'data': data,
  'has_more': false,
  'first_id': data.isEmpty ? null : data.first['id'],
  'last_id': data.isEmpty ? null : data.last['id'],
};

List<Map<String, dynamic>> _addedJson(List<Map<String, dynamic>> output) => [
  for (final item in output)
    {
      ...item,
      if (item['type'] == 'function_call') 'arguments': '',
      if (item['type'] == 'custom_tool_call') 'input': '',
      if (item['type'] == 'function_call' || item['type'] == 'custom_tool_call')
        'status': 'in_progress',
    },
];

List<Map<String, dynamic>> _events(
  List<Map<String, dynamic>> output, {
  required bool beta,
}) => [
  {
    'type': 'response.created',
    'sequence_number': 0,
    'response': _responseJson([], status: 'in_progress'),
  },
  for (var index = 0; index < output.length; index++) ...[
    {
      'type': 'response.output_item.added',
      'sequence_number': index * 2 + 1,
      'output_index': index,
      if (beta) 'agent': {'agent_name': 'researcher'},
      'item': _addedJson(output)[index],
    },
    {
      'type': 'response.output_item.done',
      'sequence_number': index * 2 + 2,
      'output_index': index,
      if (beta) 'agent': {'agent_name': 'researcher'},
      'item': output[index],
    },
  ],
  {
    'type': 'response.completed',
    'sequence_number': output.length * 2 + 1,
    'response': _responseJson(output),
  },
];

http.Response _jsonResponse(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);

http.Response _sseResponse(List<Map<String, dynamic>> events) => http.Response(
  '${events.map((event) => 'event: ${event['type']}\ndata: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);
