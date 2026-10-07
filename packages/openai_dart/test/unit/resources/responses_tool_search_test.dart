import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

// Every transport in this file is local. No API key or external API is used.
void main() {
  for (final beta in [false, true]) {
    group('tool search beta=$beta', () {
      test(
        'create sends complete writable definitions and typed search config',
        () async {
          var sends = 0;
          final input = _writableItems(beta: beta);
          final output = _returnedItems(beta: beta);
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, 'POST', '/v1/responses', beta: beta);
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': input,
                'tools': [_searchConfig()],
                'parallel_tool_calls': false,
              });
              return _jsonResponse(_response(output));
            }),
          );
          final response = await client.responses.create(
            CreateResponseRequest.fromJson({
              'model': 'fixture-model',
              'input': input,
              'tools': [_searchConfig()],
              'parallel_tool_calls': false,
            }),
            beta: beta,
          );
          expect(
            response.toolSearchCalls.single,
            isA<ToolSearchCallOutputItem>(),
          );
          expect(
            response.toolSearchOutputs.single,
            isA<ToolSearchOutputItem>(),
          );
          expect(response.toolSearchCalls.single.arguments, _arguments);
          expect(
            response.toolSearchCalls.single.execution,
            ToolSearchExecutionType.client,
          );
          expect(
            response.toolSearchOutputs.single.execution,
            ToolSearchExecutionType.client,
          );
          expect(response.output.map((item) => item.toJson()), output);
          expect(sends, 1);
        },
      );

      for (final operation in _responseOperations) {
        test('$operation retains complete returned search items', () async {
          final output = _returnedItems(beta: beta);
          final result = await _read(operation, output, beta: beta);
          expect(result, output);
        });
        test(
          '$operation accepts absent optional returned owner metadata',
          () async {
            final output = _returnedItems(beta: beta);
            for (final item in output) {
              item
                ..remove('agent')
                ..remove('created_by');
            }
            expect(await _read(operation, output, beta: beta), output);
          },
        );
        test(
          '$operation retains existing unknown enum normalization',
          () async {
            final output = _returnedItems(beta: beta);
            for (final item in output) {
              item['execution'] = 'future_execution';
              item['status'] = 'future_status';
            }
            final discovered = output[1]['tools'] as List<Map<String, dynamic>>;
            discovered[3]['execution'] = 'future_execution';
            final expected = [for (final item in output) _clone(item)];
            for (final item in expected) {
              item['execution'] = 'unknown';
              item['status'] = 'unknown';
            }
            ((expected[1]['tools'] as List)[3]
                    as Map<String, dynamic>)['execution'] =
                'unknown';
            expect(await _read(operation, output, beta: beta), expected);
          },
        );
        for (final entry in _arbitraryArguments.entries) {
          test('$operation retains required ${entry.key} arguments', () async {
            final item = _returnedCall(beta: beta, arguments: entry.value);
            expect(await _read(operation, [item], beta: beta), [item]);
          });
        }
        for (final type in ['tool_search_call', 'tool_search_output']) {
          for (final status in ['in_progress', 'completed', 'incomplete']) {
            test(
              '$operation retains $type status=$status and hosted null ID',
              () async {
                final item = type == 'tool_search_call'
                    ? _returnedCall(beta: beta)
                    : _returnedOutput(beta: beta);
                item['status'] = status;
                item['execution'] = 'server';
                item['call_id'] = null;
                if (type == 'tool_search_output') item['tools'] = <Object>[];
                expect(await _read(operation, [item], beta: beta), [item]);
              },
            );
          }
          for (final malformed in _returnedErrors(type, beta: beta)) {
            test('$operation rejects $type ${malformed.name}', () async {
              final item = type == 'tool_search_call'
                  ? _returnedCall(beta: beta)
                  : _returnedOutput(beta: beta);
              malformed.apply(item);
              await expectLater(
                _read(operation, [item], beta: beta),
                throwsA(_formatError(malformed.context)),
              );
            });
          }
        }
        for (final malformed in _definitionErrors(returned: true)) {
          test('$operation rejects ${malformed.name} definition', () async {
            final item = _returnedOutput(beta: beta);
            malformed.apply(item);
            await expectLater(
              _read(operation, [item], beta: beta),
              throwsA(_formatError(malformed.context)),
            );
          });
        }
      }

      test(
        'public accumulator exposes typed added/done items then complete final tools',
        () async {
          final output = _returnedItems(beta: beta);
          final added = [
            for (final item in output) {...item, 'status': 'in_progress'},
          ];
          final events = <Map<String, dynamic>>[
            {
              'type': 'response.created',
              'sequence_number': 0,
              'response': _response([], status: 'created'),
            },
            for (var i = 0; i < output.length; i++) ...[
              {
                'type': 'response.output_item.added',
                'sequence_number': 1 + i * 2,
                'output_index': i,
                'item': added[i],
              },
              {
                'type': 'response.output_item.done',
                'sequence_number': 2 + i * 2,
                'output_index': i,
                'item': output[i],
              },
            ],
            {
              'type': 'response.completed',
              'sequence_number': 5,
              'response': _response(output),
            },
          ];
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, 'POST', '/v1/responses', beta: beta);
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': 'Find tools.',
                'stream': true,
              });
              return _sseResponse(events);
            }),
          );
          var observed = 0;
          Response? initial;
          await for (final state
              in client.responses.createStreamWithAccumulator(
                _basicRequest,
                beta: beta,
              )) {
            final event = state.latestEvent!;
            expect(event.sequenceNumber, observed++);
            switch (event) {
              case ResponseCreatedEvent():
                initial = state.response;
                expect(state.isComplete, isFalse);
              case OutputItemAddedEvent(:final item, :final outputIndex):
                expect(item.toJson(), added[outputIndex]);
                expect(state.response, same(initial));
                expect(state.isComplete, isFalse);
              case OutputItemDoneEvent(:final item, :final outputIndex):
                expect(item.toJson(), output[outputIndex]);
                expect(state.response, same(initial));
                expect(state.isComplete, isFalse);
              case ResponseCompletedEvent():
                expect(
                  state.response!.output.map((item) => item.toJson()),
                  output,
                );
                expect(
                  state.response!.toolSearchCalls.single.callId,
                  'call_search_original',
                );
                expect(
                  state.response!.toolSearchOutputs.single.tools,
                  hasLength(4),
                );
                expect(state.isSuccessful, isTrue);
              default:
                fail('Unexpected fixture event.');
            }
            expect(state.text, isEmpty);
            expect(state.reasoning, isEmpty);
            expect(state.functionArguments, isEmpty);
          }
          expect(observed, events.length);
          expect(sends, 1);
        },
      );

      for (final execution in ['server', 'client']) {
        test(
          '$execution continuation keeps the original call ID and discovered tools',
          () async {
            var sends = 0;
            final originalId = execution == 'server'
                ? null
                : 'call_search_original';
            final call = _returnedCall(beta: beta)
              ..['call_id'] = originalId
              ..['execution'] = execution;
            final hostedOutput = _returnedOutput(beta: beta)
              ..['call_id'] = originalId
              ..['execution'] = execution;
            final client = _client(
              MockClient((request) async {
                sends++;
                _expectProtocol(request, 'POST', '/v1/responses', beta: beta);
                if (sends == 1) {
                  expect(jsonDecode(request.body), {
                    'model': 'fixture-model',
                    'input': 'Find tools.',
                    'tools': [
                      {'type': 'tool_search', 'execution': execution},
                    ],
                  });
                  return _jsonResponse(
                    _response([call, if (execution == 'server') hostedOutput]),
                  );
                }
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'previous_response_id': 'resp_search',
                  'input': execution == 'client'
                      ? [
                          {
                            'type': 'tool_search_output',
                            'call_id': originalId,
                            'execution': 'client',
                            'tools': _discoveredTools(),
                            if (beta) 'agent': {'agent_name': 'searcher'},
                          },
                        ]
                      : [call, hostedOutput],
                });
                return _jsonResponse(_response([]));
              }),
            );
            final first = await client.responses.create(
              CreateResponseRequest(
                model: 'fixture-model',
                input: const ResponseInput.text('Find tools.'),
                tools: [
                  ResponseTool.toolSearch(
                    execution: ToolSearchExecutionType.fromJson(execution),
                  ),
                ],
              ),
              beta: beta,
            );
            final returned = first.toolSearchCalls.single;
            expect(returned.callId, originalId);
            final nextInput = execution == 'client'
                ? ResponseInput.items([
                    ToolSearchOutputItemParam.fromJson({
                      'type': 'tool_search_output',
                      'call_id': returned.callId,
                      'execution': 'client',
                      'tools': _discoveredTools(),
                      if (beta) 'agent': {'agent_name': 'searcher'},
                    }),
                  ])
                : ResponseInput.fromOutputItems(
                    first.output.map((item) => item.toJson()).toList(),
                  );
            await client.responses.create(
              CreateResponseRequest(
                model: 'fixture-model',
                input: nextInput,
                previousResponseId: first.id,
              ),
              beta: beta,
            );
            expect(sends, 2);
          },
        );
      }

      test(
        'raw output history preserves arbitrary arguments without writable object coercion',
        () async {
          var sends = 0;
          final output = [
            for (final value in _arbitraryArguments.values)
              _returnedCall(beta: beta, arguments: value),
            _returnedOutput(beta: beta),
          ];
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, 'POST', '/v1/responses', beta: beta);
              if (sends == 1) return _jsonResponse(_response(output));
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': output,
                'previous_response_id': 'resp_search',
              });
              return _jsonResponse(_response([]));
            }),
          );
          final first = await client.responses.create(
            _basicRequest,
            beta: beta,
          );
          await client.responses.create(
            CreateResponseRequest(
              model: 'fixture-model',
              input: ResponseInput.fromOutputItems(
                first.output.map((item) => item.toJson()).toList(),
              ),
              previousResponseId: first.id,
            ),
            beta: beta,
          );
          expect(sends, 2);
        },
      );

      test(
        'future discovered namespace tool survives every returned path',
        () async {
          final output = _returnedOutput(beta: beta);
          final tools = output['tools'] as List<Map<String, dynamic>>;
          (tools[2]['tools'] as List<Map<String, dynamic>>).add(
            _futureNamespaceTool(),
          );
          for (final operation in _responseOperations) {
            expect(await _read(operation, [output], beta: beta), [
              output,
            ], reason: operation);
          }
        },
      );
    });
  }

  for (final operation in _conversationOperations) {
    test(
      '$operation retains required search fields and complete discovered definitions',
      () async {
        final items = _returnedItems();
        if (operation == 'conversation-retrieve') {
          for (final item in items) {
            expect(await _read(operation, [item]), [item]);
          }
        } else {
          expect(await _read(operation, items), items);
        }
      },
    );
    for (final entry in _arbitraryArguments.entries) {
      test(
        '$operation retains ${entry.key} arguments and explicit null call ID',
        () async {
          final call = _returnedCall(arguments: entry.value)
            ..['call_id'] = null;
          expect(await _read(operation, [call]), [call]);
        },
      );
    }
    for (final type in ['tool_search_call', 'tool_search_output']) {
      for (final status in ['in_progress', 'completed', 'incomplete']) {
        test(
          '$operation retains $type status=$status and hosted empty results',
          () async {
            final item = type == 'tool_search_call'
                ? _returnedCall()
                : _returnedOutput();
            item['status'] = status;
            item['execution'] = 'server';
            item['call_id'] = null;
            item.remove('created_by');
            if (type == 'tool_search_output') item['tools'] = <Object>[];
            expect(await _read(operation, [item]), [item]);
          },
        );
      }
      for (final malformed in _returnedErrors(type)) {
        test('$operation rejects $type ${malformed.name}', () async {
          final item = type == 'tool_search_call'
              ? _returnedCall()
              : _returnedOutput();
          malformed.apply(item);
          await expectLater(
            _read(operation, [item]),
            throwsA(_formatError(malformed.context)),
          );
        });
      }
    }
    for (final malformed in _definitionErrors(returned: true)) {
      test('$operation rejects ${malformed.name} definition', () async {
        final item = _returnedOutput();
        malformed.apply(item);
        await expectLater(
          _read(operation, [item]),
          throwsA(_formatError(malformed.context)),
        );
      });
    }
    test('$operation retains a future namespace tool', () async {
      final item = _returnedOutput();
      final tools = item['tools'] as List<Map<String, dynamic>>;
      (tools[2]['tools'] as List<Map<String, dynamic>>).add(
        _futureNamespaceTool(),
      );
      expect(await _read(operation, [item]), [item]);
    });
    test('$operation retains existing unknown enum normalization', () async {
      for (final item in _returnedItems()) {
        item['execution'] = 'future_execution';
        item['status'] = 'future_status';
        final expected = _clone(item)
          ..['execution'] = 'unknown'
          ..['status'] = 'unknown';
        expect(await _read(operation, [item]), [expected]);
      }
    });
  }

  test(
    'conversation creation sends writable discovered tools with original IDs',
    () async {
      var sends = 0;
      final input = _writableItems();
      final client = _client(
        MockClient((request) async {
          sends++;
          _expectProtocol(request, 'POST', '/v1/conversations');
          expect(jsonDecode(request.body), {
            'items': input,
            'metadata': {'fixture': 'tool-search'},
          });
          return _jsonResponse({
            'id': 'conv_search',
            'object': 'conversation',
            'created_at': 1,
            'metadata': {'fixture': 'tool-search'},
          });
        }),
      );
      final conversation = await client.conversations.create(
        ConversationCreateRequest.fromJson({
          'items': input,
          'metadata': const {'fixture': 'tool-search'},
        }),
      );
      expect(conversation.id, 'conv_search');
      expect(conversation.metadata, {'fixture': 'tool-search'});
      expect(sends, 1);
    },
  );

  for (final factory in [
    'response request',
    'conversation request',
    'conversation items request',
  ]) {
    test(
      '$factory retains empty tools and normalizes nullable optional input metadata',
      () {
        final input = <Map<String, dynamic>>[
          {
            'type': 'tool_search_call',
            'arguments': <String, dynamic>{},
            'id': null,
            'call_id': null,
            'status': null,
            'agent': null,
          },
          {
            'type': 'tool_search_output',
            'tools': <Object>[],
            'id': null,
            'call_id': null,
            'status': null,
            'agent': null,
          },
        ];
        expect(_parseWritable(factory, input), [
          {'type': 'tool_search_call', 'arguments': <String, dynamic>{}},
          {'type': 'tool_search_output', 'tools': <Object>[]},
        ]);
      },
    );
    test(
      '$factory preserves minimally defined dotted discovered functions',
      () {
        final input = _writableItems();
        expect(_parseWritable(factory, input), input);
      },
    );
    test('$factory preserves supplied empty optional identifiers', () {
      final input = _writableItems();
      for (final item in input) {
        item['id'] = '';
        item['call_id'] = '';
      }
      expect(_parseWritable(factory, input), input);
    });
    test('$factory retains existing unknown enum normalization', () {
      final input = _writableItems();
      for (final item in input) {
        item['execution'] = 'future_execution';
        item['status'] = 'future_status';
      }
      final tools = input[1]['tools'] as List<Map<String, dynamic>>;
      tools[3]['execution'] = 'future_execution';
      final expected = [for (final item in input) _clone(item)];
      for (final item in expected) {
        item['execution'] = 'unknown';
        item['status'] = 'unknown';
      }
      ((expected[1]['tools'] as List)[3] as Map<String, dynamic>)['execution'] =
          'unknown';
      expect(_parseWritable(factory, input), expected);
    });
    test('$factory preserves future discovered namespace definitions', () {
      final input = _writableItems();
      final tools = input[1]['tools'] as List<Map<String, dynamic>>;
      (tools[2]['tools'] as List<Map<String, dynamic>>).add(
        _futureNamespaceTool(),
      );
      expect(_parseWritable(factory, input), input);
    });
    for (final type in ['tool_search_call', 'tool_search_output']) {
      for (final malformed in _writableErrors(type)) {
        test('$factory rejects $type ${malformed.name}', () {
          final item = type == 'tool_search_call'
              ? _writableCall()
              : _writableOutput();
          malformed.apply(item);
          expect(
            () => _parseWritable(factory, [item]),
            throwsA(_formatError(malformed.context)),
          );
        });
      }
    }
    for (final malformed in _definitionErrors(returned: false)) {
      test('$factory rejects ${malformed.name} definition', () {
        final item = _writableOutput();
        malformed.apply(item);
        expect(
          () => _parseWritable(factory, [item]),
          throwsA(_formatError(malformed.context)),
        );
      });
    }
  }

  test(
    'ordinary namespaces and discovered namespaces retain distinct naming rules',
    () {
      final namespace = _discoveredTools()[2];
      expect(
        () => CreateResponseRequest.fromJson({
          'model': 'fixture-model',
          'input': 'Start.',
          'tools': [namespace],
        }),
        throwsA(_formatError('tools[0].name')),
      );
      expect(_parseWritable('response request', [_writableOutput()]), [
        _writableOutput(),
      ]);
      final ordinary = _clone(namespace);
      final nested = ordinary['tools'] as List<dynamic>;
      (nested[0] as Map<String, dynamic>)['name'] = 'lookup';
      (nested[1] as Map<String, dynamic>)['name'] = 'details';
      final request = CreateResponseRequest.fromJson({
        'model': 'fixture-model',
        'input': 'Start.',
        'tools': [ordinary],
      });
      expect(request.tools!.single.toJson(), ordinary);
    },
  );

  test(
    'returned top-level function nullable required keys remain distinct from nested discovery',
    () async {
      final item = _returnedOutput();
      final tools = item['tools'] as List<Map<String, dynamic>>;
      tools[0] = {
        'type': 'function',
        'name': 'lookup',
        'parameters': null,
        'strict': null,
      };
      // Optional null schema fields may normalize, but returned required nulls remain.
      expect(await _read('create', [item]), [item]);
      expect(_parseWritable('response request', [_writableOutput()]), [
        _writableOutput(),
      ]);
    },
  );
}

const _basicRequest = CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.text('Find tools.'),
);
const _arguments = <String, dynamic>{
  'query': 'fixture tools',
  'filters': {'enabled': false, 'count': 0},
};
const _parameters = <String, dynamic>{
  'type': 'object',
  'properties': {
    'query': {'type': 'string'},
  },
  'required': ['query'],
  'additionalProperties': false,
};
const _outputSchema = <String, dynamic>{
  'type': 'object',
  'properties': {
    'value': {'type': 'integer'},
  },
};
const _arbitraryArguments = <String, Object?>{
  'null': null,
  'string': 'query text',
  'integer': 0,
  'double': 1.5,
  'boolean': false,
  'list': [
    null,
    false,
    0,
    'query',
    {
      'nested': ['value'],
    },
  ],
  'object': _arguments,
};
const _lifecycles = [
  'created',
  'queued',
  'in_progress',
  'completed',
  'failed',
  'incomplete',
];
final List<String> _responseOperations = [
  'create',
  'retrieve',
  'input-list',
  'item-added',
  'item-done',
  for (final kind in _lifecycles) 'lifecycle-$kind',
  for (final kind in _lifecycles) 'accumulator-$kind',
];
const _conversationOperations = [
  'conversation-create-items',
  'conversation-list',
  'conversation-retrieve',
];

OpenAIClient _client(http.Client transport) {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('fixture-key'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  addTearDown(client.close);
  addTearDown(transport.close);
  return client;
}

void _expectProtocol(
  http.Request request,
  String method,
  String path, {
  bool beta = false,
  Map<String, List<String>> query = const {},
}) {
  expect(request.method, method);
  expect(request.url.path, path);
  expect(request.url.queryParametersAll, {
    ...query,
    if (beta) 'beta': ['true'],
  });
  expect(request.headers['Authorization'], 'Bearer fixture-key');
  expect(
    request.headers['OpenAI-Beta'],
    beta ? 'responses_multi_agent=v1' : null,
  );
  if (method == 'GET') expect(request.body, isEmpty);
}

Future<List<Map<String, dynamic>>> _read(
  String operation,
  List<Map<String, dynamic>> items, {
  bool beta = false,
}) async {
  var sends = 0;
  final isConversation = operation.startsWith('conversation-');
  final eventType = operation.startsWith('accumulator-')
      ? operation.substring('accumulator-'.length)
      : operation.startsWith('lifecycle-')
      ? operation.substring('lifecycle-'.length)
      : null;
  final client = _client(
    MockClient((request) async {
      sends++;
      if (operation == 'retrieve') {
        _expectProtocol(
          request,
          'GET',
          '/v1/responses/resp_search',
          beta: beta,
          query: {
            'include[]': [
              'reasoning.encrypted_content',
              'web_search_call.results',
            ],
          },
        );
        return _jsonResponse(_response(items));
      }
      if (operation == 'input-list') {
        _expectProtocol(
          request,
          'GET',
          '/v1/responses/resp_search/input_items',
          beta: beta,
          query: {
            'after': ['item_before'],
            'before': ['item_after'],
            'limit': ['20'],
            'order': ['asc'],
            'include[]': ['reasoning.encrypted_content'],
          },
        );
        return _jsonResponse(_list(items));
      }
      if (isConversation) {
        if (operation == 'conversation-create-items') {
          _expectProtocol(
            request,
            'POST',
            '/v1/conversations/conv_search/items',
          );
          expect(jsonDecode(request.body), {'items': _writableItems()});
        } else if (operation == 'conversation-list') {
          _expectProtocol(
            request,
            'GET',
            '/v1/conversations/conv_search/items',
            query: {
              'after': ['item_before'],
              'limit': ['20'],
              'order': ['asc'],
              'include[]': [
                'reasoning.encrypted_content',
                'web_search_call.results',
              ],
            },
          );
        } else {
          _expectProtocol(
            request,
            'GET',
            '/v1/conversations/conv_search/items/${_resourceId(items.single)}',
            query: {
              'include[]': ['reasoning.encrypted_content'],
            },
          );
        }
        return _jsonResponse(
          operation == 'conversation-retrieve' ? items.single : _list(items),
        );
      }
      _expectProtocol(request, 'POST', '/v1/responses', beta: beta);
      expect(jsonDecode(request.body), {
        'model': 'fixture-model',
        'input': 'Find tools.',
        if (operation != 'create') 'stream': true,
      });
      if (operation == 'create') return _jsonResponse(_response(items));
      if (operation == 'item-added' || operation == 'item-done') {
        return _sseResponse([
          for (var i = 0; i < items.length; i++)
            {
              'type':
                  'response.output_item.${operation == 'item-added' ? 'added' : 'done'}',
              'sequence_number': i,
              'output_index': i,
              'item': items[i],
              if (beta) 'agent': {'agent_name': 'searcher'},
            },
        ]);
      }
      return _sseResponse([
        {
          'type': 'response.$eventType',
          'sequence_number': 1,
          'response': _response(items, status: eventType!),
        },
      ]);
    }),
  );
  final List<Map<String, dynamic>> result;
  if (operation == 'create') {
    result = (await client.responses.create(
      _basicRequest,
      beta: beta,
    )).output.map((item) => item.toJson()).toList();
  } else if (operation == 'retrieve') {
    result = (await client.responses.retrieve(
      'resp_search',
      include: [Include.reasoningEncryptedContent, Include.webSearchResults],
      beta: beta,
    )).output.map((item) => item.toJson()).toList();
  } else if (operation == 'input-list') {
    final listed = await client.responses.inputItems.list(
      'resp_search',
      after: 'item_before',
      before: 'item_after',
      limit: 20,
      order: 'asc',
      include: [Include.reasoningEncryptedContent],
      beta: beta,
    );
    for (final item in listed.data) {
      switch (item.toJson()['type']) {
        case 'tool_search_call':
          expect(item, isA<ToolSearchCallResourceItem>());
        case 'tool_search_output':
          expect(item, isA<ToolSearchOutputResourceItem>());
      }
    }
    result = listed.data.map((item) => item.toJson()).toList();
  } else if (operation == 'conversation-create-items') {
    result = (await client.conversations.items.create(
      'conv_search',
      ItemsCreateRequest.fromJson({'items': _writableItems()}),
    )).data.map((item) => item.toJson()).toList();
  } else if (operation == 'conversation-list') {
    result = (await client.conversations.items.list(
      'conv_search',
      after: 'item_before',
      limit: 20,
      order: 'asc',
      include: ['reasoning.encrypted_content', 'web_search_call.results'],
    )).data.map((item) => item.toJson()).toList();
  } else if (operation == 'conversation-retrieve') {
    result = [
      (await client.conversations.items.retrieve(
        'conv_search',
        _resourceId(items.single),
        include: ['reasoning.encrypted_content'],
      )).toJson(),
    ];
  } else if (operation.startsWith('accumulator-')) {
    final states = await client.responses
        .createStreamWithAccumulator(_basicRequest, beta: beta)
        .toList();
    final state = states.single;
    expect(state.latestEvent!.type, 'response.$eventType');
    expect(state.response, isNotNull);
    expect(state.text, isEmpty);
    expect(state.reasoning, isEmpty);
    expect(
      state.status.toJson(),
      eventType == 'created' ? 'in_progress' : eventType,
    );
    expect(
      state.isComplete,
      ['completed', 'failed', 'incomplete'].contains(eventType),
    );
    result = state.response!.output.map((item) => item.toJson()).toList();
  } else {
    final events = await client.responses
        .createStream(_basicRequest, beta: beta)
        .toList();
    expect(events.whereType<UnknownEvent>(), isEmpty);
    if (operation == 'item-added' || operation == 'item-done') {
      for (var i = 0; i < events.length; i++) {
        final event = events[i];
        expect(event.sequenceNumber, i);
        switch (event) {
          case OutputItemAddedEvent(:final outputIndex, :final agent) ||
              OutputItemDoneEvent(:final outputIndex, :final agent):
            expect(outputIndex, i);
            expect(agent?.agentName, beta ? 'searcher' : null);
          default:
            fail('Expected a typed output-item event.');
        }
      }
    }
    result = [
      for (final event in events)
        ...switch (event) {
          OutputItemAddedEvent(:final item) ||
          OutputItemDoneEvent(:final item) => [item.toJson()],
          ResponseCreatedEvent(:final response) ||
          ResponseQueuedEvent(:final response) ||
          ResponseInProgressEvent(:final response) ||
          ResponseCompletedEvent(:final response) ||
          ResponseFailedEvent(:final response) ||
          ResponseIncompleteEvent(
            :final response,
          ) => response.output.map((item) => item.toJson()),
          _ => throw StateError('Unexpected fixture event ${event.type}'),
        },
    ];
  }
  expect(sends, 1);
  return result;
}

String _resourceId(Map<String, dynamic> item) =>
    item['type'] == 'tool_search_call' ? 'tsc_search' : 'tso_search';

List<Map<String, dynamic>> _parseWritable(
  String factory,
  List<Map<String, dynamic>> items,
) {
  final value = switch (factory) {
    'response request' => CreateResponseRequest.fromJson({
      'model': 'fixture-model',
      'input': items,
    }).toJson()['input'],
    'conversation request' => ConversationCreateRequest.fromJson({
      'items': items,
    }).toJson()['items'],
    _ => ItemsCreateRequest.fromJson({'items': items}).toJson()['items'],
  };
  return (value as List).cast<Map<String, dynamic>>();
}

Map<String, dynamic> _writableCall({bool beta = false}) => {
  'type': 'tool_search_call',
  'id': 'tsc_input',
  'call_id': 'call_search_original',
  'execution': 'client',
  'arguments': _arguments,
  'status': 'completed',
  if (beta) 'agent': {'agent_name': 'searcher'},
};
Map<String, dynamic> _writableOutput({bool beta = false}) => {
  'type': 'tool_search_output',
  'id': 'tso_input',
  'call_id': 'call_search_original',
  'execution': 'client',
  'tools': _discoveredTools(),
  'status': 'completed',
  if (beta) 'agent': {'agent_name': 'searcher'},
};
List<Map<String, dynamic>> _writableItems({bool beta = false}) => [
  _writableCall(beta: beta),
  _writableOutput(beta: beta),
];
Map<String, dynamic> _returnedCall({
  bool beta = false,
  Object? arguments = _arguments,
}) => {
  'type': 'tool_search_call',
  'id': 'tsc_search',
  'call_id': 'call_search_original',
  'execution': 'client',
  'arguments': arguments,
  'status': 'completed',
  'created_by': 'fixture-actor',
  if (beta) 'agent': {'agent_name': 'searcher'},
};
Map<String, dynamic> _returnedOutput({bool beta = false}) => {
  'type': 'tool_search_output',
  'id': 'tso_search',
  'call_id': 'call_search_original',
  'execution': 'client',
  'tools': _discoveredTools(),
  'status': 'completed',
  'created_by': 'fixture-actor',
  if (beta) 'agent': {'agent_name': 'searcher'},
};
List<Map<String, dynamic>> _returnedItems({bool beta = false}) => [
  _returnedCall(beta: beta),
  _returnedOutput(beta: beta),
];
Map<String, dynamic> _searchConfig() => {
  'type': 'tool_search',
  'execution': 'client',
  'description': '',
  'parameters': _parameters,
};
List<Map<String, dynamic>> _discoveredTools() => [
  {
    'type': 'function',
    'name': 'lookup',
    'parameters': _parameters,
    'strict': false,
    'description': '',
    'allowed_callers': ['direct', 'programmatic'],
    'defer_loading': false,
    'output_schema': _outputSchema,
    'async': true,
  },
  {
    'type': 'custom',
    'name': 'render',
    'description': '',
    'format': {'type': 'text'},
    'allowed_callers': ['programmatic', 'direct'],
    'defer_loading': true,
    'async': false,
  },
  {
    'type': 'namespace',
    'name': 'crm',
    'description': '',
    'tools': <Map<String, dynamic>>[
      {'type': 'function', 'name': 'customers.lookup'},
      {
        'type': 'function',
        'name': 'customers.details',
        'description': '',
        'parameters': _parameters,
        'strict': true,
        'allowed_callers': ['direct', 'programmatic'],
        'defer_loading': true,
        'output_schema': _outputSchema,
        'async': false,
      },
      {
        'type': 'custom',
        'name': 'render',
        'description': '',
        'format': {'type': 'text'},
        'allowed_callers': ['direct'],
        'defer_loading': false,
        'async': true,
      },
    ],
  },
  _searchConfig(),
];
Map<String, dynamic> _futureNamespaceTool() => {
  'type': 'future_namespace_tool',
  'name': 'future',
  'payload': {
    'nested': [
      false,
      null,
      0,
      {'value': 'preserved'},
    ],
  },
};

Map<String, dynamic> _response(
  List<Map<String, dynamic>> items, {
  String status = 'completed',
}) => {
  'id': 'resp_search',
  'object': 'response',
  'created_at': 1,
  'status': status == 'created' ? 'in_progress' : status,
  'model': 'fixture-model',
  'output': items,
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': [_searchConfig()],
  'parallel_tool_calls': false,
  'metadata': <String, String>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};
Map<String, dynamic> _list(List<Map<String, dynamic>> items) => {
  'object': 'list',
  'data': items,
  'has_more': false,
  'first_id': 'tsc_search',
  'last_id': 'tso_search',
};
http.Response _jsonResponse(Map<String, dynamic> payload) => http.Response(
  jsonEncode(payload),
  200,
  headers: {'content-type': 'application/json'},
);
http.Response _sseResponse(List<Map<String, dynamic>> events) => http.Response(
  '${events.map((event) => 'event: ${event['type']}\ndata: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);
Map<String, dynamic> _clone(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
Matcher _formatError(String context) => isA<FormatException>().having(
  (error) => error.message,
  'indexed field context',
  allOf([for (final part in context.split('.')) contains(part)]),
);

class _Malformed {
  final String name;
  final String context;
  final void Function(Map<String, dynamic>) apply;
  const _Malformed(this.name, this.context, this.apply);
}

List<_Malformed> _returnedErrors(String type, {bool beta = false}) => [
  for (final field in [
    'id',
    'call_id',
    'execution',
    'status',
    if (type == 'tool_search_call') 'arguments' else 'tools',
  ])
    _Malformed('missing $field', field, (item) => item.remove(field)),
  for (final field in [
    'id',
    'execution',
    'status',
    if (type == 'tool_search_output') 'tools',
    'created_by',
  ])
    _Malformed('null $field', field, (item) => item[field] = null),
  for (final field in ['id', 'call_id', 'execution', 'status', 'created_by'])
    _Malformed('invalid $field', field, (item) => item[field] = 4),
  if (type == 'tool_search_output') ...[
    _Malformed(
      'object tools',
      'tools',
      (item) => item['tools'] = <String, dynamic>{},
    ),
    _Malformed('scalar tool', 'tools[0]', (item) => item['tools'] = [4]),
  ],
  if (beta) ...[
    _Malformed('null agent', 'agent', (item) => item['agent'] = null),
    _Malformed('scalar agent', 'agent', (item) => item['agent'] = 4),
    _Malformed(
      'missing agent name',
      'agent.agent_name',
      (item) => item['agent'] = <String, dynamic>{},
    ),
    _Malformed(
      'null agent name',
      'agent.agent_name',
      (item) => item['agent'] = {'agent_name': null},
    ),
    _Malformed(
      'invalid agent name',
      'agent.agent_name',
      (item) => item['agent'] = {'agent_name': false},
    ),
  ],
];

List<_Malformed> _writableErrors(String type) => [
  _Malformed(
    'missing ${type == 'tool_search_call' ? 'arguments' : 'tools'}',
    type == 'tool_search_call' ? 'arguments' : 'tools',
    (item) => item.remove(type == 'tool_search_call' ? 'arguments' : 'tools'),
  ),
  if (type == 'tool_search_call')
    for (final value in [null, false, 4, 'query', <Object>[]])
      _Malformed(
        'arguments=$value',
        'arguments',
        (item) => item['arguments'] = value,
      ),
  if (type == 'tool_search_output') ...[
    _Malformed('null tools', 'tools', (item) => item['tools'] = null),
    _Malformed(
      'object tools',
      'tools',
      (item) => item['tools'] = <String, dynamic>{},
    ),
    _Malformed('scalar tool', 'tools[0]', (item) => item['tools'] = [4]),
  ],
  for (final field in ['id', 'call_id', 'execution', 'status'])
    _Malformed('invalid $field', field, (item) => item[field] = false),
  _Malformed('null execution', 'execution', (item) => item['execution'] = null),
  _Malformed('scalar agent', 'agent', (item) => item['agent'] = 4),
  _Malformed(
    'missing agent name',
    'agent.agent_name',
    (item) => item['agent'] = <String, dynamic>{},
  ),
  _Malformed(
    'invalid agent name',
    'agent.agent_name',
    (item) => item['agent'] = {'agent_name': false},
  ),
];

List<_Malformed> _definitionErrors({required bool returned}) {
  _Malformed top(
    String name,
    String field,
    Object? value, {
    bool missing = false,
  }) => _Malformed(name, 'tools[0].$field', (item) {
    final function = (item['tools'] as List<Map<String, dynamic>>)[0];
    if (missing) {
      function.remove(field);
    } else {
      function[field] = value;
    }
  });
  _Malformed nested(
    String name,
    String field,
    Object? value, {
    bool missing = false,
  }) => _Malformed(name, 'tools[2].tools[0].$field', (item) {
    final tools = item['tools'] as List<Map<String, dynamic>>;
    final function = (tools[2]['tools'] as List<Map<String, dynamic>>)[0];
    if (missing) {
      function.remove(field);
    } else {
      function[field] = value;
    }
  });
  return [
    top('missing function name', 'name', null, missing: true),
    top('null function name', 'name', null),
    top('invalid function name', 'name', false),
    top('invalid function parameters', 'parameters', []),
    top('invalid function strict', 'strict', 4),
    top('invalid function description', 'description', []),
    top('invalid function allowed callers', 'allowed_callers', false),
    top('invalid function output schema', 'output_schema', []),
    top('invalid function async', 'async', 'true'),
    top('null function async', 'async', null),
    top('invalid function defer loading', 'defer_loading', 'true'),
    top('null function defer loading', 'defer_loading', null),
    if (returned) ...[
      top(
        'missing returned function parameters',
        'parameters',
        null,
        missing: true,
      ),
      top('missing returned function strict', 'strict', null, missing: true),
    ],
    nested('missing discovered name', 'name', null, missing: true),
    nested('null discovered name', 'name', null),
    nested('empty discovered name', 'name', ''),
    nested('invalid discovered newline name', 'name', 'bad\nname'),
    nested('invalid discovered name characters', 'name', 'bad/name'),
    nested('invalid discovered parameters', 'parameters', 4),
    nested('invalid discovered strict', 'strict', 'false'),
    nested('invalid discovered async', 'async', 'true'),
    nested('null discovered async', 'async', null),
    nested('invalid discovered defer loading', 'defer_loading', 4),
    nested('invalid discovered description', 'description', false),
    nested('invalid discovered callers', 'allowed_callers', false),
    nested('invalid discovered output schema', 'output_schema', false),
    _Malformed(
      'scalar namespace tool',
      'tools[2].tools[0]',
      (item) => (item['tools'] as List<Map<String, dynamic>>)[2]['tools'] = [4],
    ),
    _Malformed(
      'null namespace tools',
      'tools[2].tools',
      (item) =>
          (item['tools'] as List<Map<String, dynamic>>)[2]['tools'] = null,
    ),
    _Malformed(
      'missing namespace tools',
      'tools[2].tools',
      (item) =>
          (item['tools'] as List<Map<String, dynamic>>)[2].remove('tools'),
    ),
    _Malformed(
      'null namespace description',
      'tools[2].description',
      (item) =>
          (item['tools'] as List<Map<String, dynamic>>)[2]['description'] =
              null,
    ),
    _Malformed(
      'missing namespace name',
      'tools[2].name',
      (item) => (item['tools'] as List<Map<String, dynamic>>)[2].remove('name'),
    ),
    _Malformed(
      'invalid nested custom async',
      'tools[2].tools[2].async',
      (item) =>
          ((item['tools'] as List<Map<String, dynamic>>)[2]['tools']
                  as List<Map<String, dynamic>>)[2]['async'] =
              4,
    ),
    _Malformed(
      'invalid nested custom defer loading',
      'tools[2].tools[2].defer_loading',
      (item) =>
          ((item['tools'] as List<Map<String, dynamic>>)[2]['tools']
                  as List<Map<String, dynamic>>)[2]['defer_loading'] =
              null,
    ),
    _Malformed(
      'null search execution',
      'tools[3].execution',
      (item) =>
          (item['tools'] as List<Map<String, dynamic>>)[3]['execution'] = null,
    ),
    _Malformed(
      'invalid search description',
      'tools[3].description',
      (item) =>
          (item['tools'] as List<Map<String, dynamic>>)[3]['description'] = 4,
    ),
    _Malformed(
      'invalid search parameters',
      'tools[3].parameters',
      (item) => (item['tools'] as List<Map<String, dynamic>>)[3]['parameters'] =
          <Object>[],
    ),
  ];
}
