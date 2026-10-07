import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final beta in [false, true]) {
    for (final entry in _toolCases().entries) {
      for (final operation in ['create', 'stream', 'retrieve']) {
        test('$operation shell definition ${entry.key} beta=$beta', () async {
          final (raw, expected) = entry.value;
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: beta);
              expect(request.method, operation == 'retrieve' ? 'GET' : 'POST');
              expect(
                request.url.path,
                operation == 'retrieve'
                    ? '/v1/responses/resp_shell'
                    : '/v1/responses',
              );
              expect(
                request.url.queryParameters,
                beta ? {'beta': 'true'} : isEmpty,
              );
              if (operation != 'retrieve') {
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': 'Describe the commands.',
                  'tools': [expected],
                  'tool_choice': {'type': 'shell'},
                  if (operation == 'stream') 'stream': true,
                });
              }
              final response = _responseJson(
                tools: [expected],
                output: [
                  {
                    'type': 'additional_tools',
                    'id': 'additional_shell',
                    'role': 'developer',
                    'tools': [expected],
                    if (beta) 'agent': {'agent_name': 'shell_worker'},
                  },
                ],
              );
              return operation == 'stream'
                  ? _sseResponse(_lifecycle(response))
                  : _jsonResponse(response);
            }),
          );
          final request = CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': 'Describe the commands.',
            'tools': [raw],
            'tool_choice': const {'type': 'shell'},
          });
          expect(request.tools!.single, isA<ShellTool>());
          expect(request.toolChoice, isA<ResponseToolChoiceShell>());
          final Response response;
          if (operation == 'retrieve') {
            response = await client.responses.retrieve(
              'resp_shell',
              beta: beta,
            );
          } else if (operation == 'stream') {
            final events = await client.responses
                .createStream(request, beta: beta)
                .toList();
            expect(events.whereType<UnknownEvent>(), isEmpty);
            response = (events.last as ResponseCompletedEvent).response;
          } else {
            response = await client.responses.create(request, beta: beta);
          }
          final additional =
              response.output.single as AdditionalToolsOutputItem;
          final returned = additional.tools.single as ShellTool;
          expect(returned.toJson(), expected);
          expect(additional.agent?.agentName, beta ? 'shell_worker' : null);
          expect(sends, 1);
        });
      }
    }

    for (final operation in ['create', 'stream', 'retrieve', 'list-input']) {
      test(
        '$operation exact returned shell calls and results beta=$beta',
        () async {
          final calls = _returnedItems(beta: beta);
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: beta);
              expect(
                request.method,
                operation == 'retrieve' || operation == 'list-input'
                    ? 'GET'
                    : 'POST',
              );
              expect(request.url.path, switch (operation) {
                'retrieve' => '/v1/responses/resp_shell',
                'list-input' => '/v1/responses/resp_shell/input_items',
                _ => '/v1/responses',
              });
              expect(request.url.queryParameters, {
                if (beta) 'beta': 'true',
                if (operation == 'list-input') ...{
                  'after': 'shell_before',
                  'before': 'shell_after',
                  'limit': '25',
                  'order': 'desc',
                },
              });
              if (operation == 'create' || operation == 'stream') {
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': 'Describe the commands.',
                  if (operation == 'stream') 'stream': true,
                });
              }
              final response = _responseJson(output: calls);
              return switch (operation) {
                'stream' => _sseResponse(_lifecycle(response)),
                'list-input' => _jsonResponse(_listJson(calls)),
                _ => _jsonResponse(response),
              };
            }),
          );
          if (operation == 'list-input') {
            final page = await client.responses.inputItems.list(
              'resp_shell',
              after: 'shell_before',
              before: 'shell_after',
              limit: 25,
              order: 'desc',
              beta: beta,
            );
            expect(
              page.data.map((item) => item.toJson()).toList(),
              calls.map(_normalizeReturned).toList(),
            );
            for (var i = 0; i < page.data.length; i++) {
              final item = page.data[i];
              if (calls[i]['type'] == 'shell_call') {
                final call = item as ShellCallResourceItem;
                expect(call.agent?.agentName, beta ? 'shell_worker' : null);
                expect(
                  call.toShellCallInputItem().toJson(),
                  _writable(calls[i]),
                );
                expect(call.createdBy, 'creator_call_$i');
                expect(call.action.commands, [
                  'echo synthetic-$i',
                  'echo second-$i',
                ]);
                expect(call.action.commands.clear, throwsUnsupportedError);
              } else {
                final result = item as ShellCallOutputResourceItem;
                expect(result.agent?.agentName, beta ? 'shell_worker' : null);
                expect(
                  result.toShellCallOutputInputItem().toJson(),
                  _writable(calls[i]),
                );
                expect(
                  result.output.first.outcome,
                  isA<ShellCallExitOutcome>(),
                );
                expect(
                  result.output.last.outcome,
                  isA<ShellCallTimeoutOutcome>(),
                );
                expect(result.output.clear, throwsUnsupportedError);
              }
            }
          } else {
            final Response response;
            if (operation == 'retrieve') {
              response = await client.responses.retrieve(
                'resp_shell',
                beta: beta,
              );
            } else if (operation == 'stream') {
              final events = await client.responses
                  .createStream(_request(), beta: beta)
                  .toList();
              _expectOutputs(
                events
                    .whereType<OutputItemAddedEvent>()
                    .map((event) => event.item)
                    .toList(),
                calls,
                beta: beta,
              );
              _expectOutputs(
                events
                    .whereType<OutputItemDoneEvent>()
                    .map((event) => event.item)
                    .toList(),
                calls,
                beta: beta,
              );
              expect(events.whereType<UnknownEvent>(), isEmpty);
              response = (events.last as ResponseCompletedEvent).response;
            } else {
              response = await client.responses.create(_request(), beta: beta);
            }
            _expectOutputs(response.output, calls, beta: beta);
          }
          expect(sends, 1);
        },
      );
    }

    for (final operation in [
      'conversation-create',
      'create',
      'list',
      'retrieve-call',
      'retrieve-result',
    ]) {
      test(
        'conversation $operation shell directional contracts beta-metadata=$beta',
        () async {
          final calls = _returnedItems(beta: beta);
          final writable = calls.map(_writable).toList();
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: false);
              expect(
                request.url.queryParameters,
                operation == 'list'
                    ? {'after': 'shell_before', 'limit': '25', 'order': 'asc'}
                    : isEmpty,
              );
              expect(
                request.method,
                operation == 'conversation-create' || operation == 'create'
                    ? 'POST'
                    : 'GET',
              );
              expect(request.url.path, switch (operation) {
                'conversation-create' => '/v1/conversations',
                'retrieve-call' => '/v1/conversations/conv_shell/items/shell_0',
                'retrieve-result' =>
                  '/v1/conversations/conv_shell/items/shell_1',
                _ => '/v1/conversations/conv_shell/items',
              });
              if (operation == 'conversation-create' || operation == 'create') {
                expect(jsonDecode(request.body), {'items': writable});
              }
              return _jsonResponse(switch (operation) {
                'conversation-create' => {
                  'id': 'conv_shell',
                  'object': 'conversation',
                  'created_at': 1700000000,
                  'metadata': <String, dynamic>{},
                },
                'retrieve-call' => calls[0],
                'retrieve-result' => calls[1],
                _ => _listJson(calls),
              });
            }),
          );
          switch (operation) {
            case 'conversation-create':
              final conversation = await client.conversations.create(
                ConversationCreateRequest(
                  items: writable.map(Item.fromJson).toList(),
                ),
              );
              expect(conversation.id, 'conv_shell');
            case 'create':
              final page = await client.conversations.items.create(
                'conv_shell',
                ItemsCreateRequest(items: writable.map(Item.fromJson).toList()),
              );
              _expectConversationItems(page.data, calls, beta: beta);
            case 'list':
              final page = await client.conversations.items.list(
                'conv_shell',
                after: 'shell_before',
                limit: 25,
                order: 'asc',
              );
              _expectConversationItems(page.data, calls, beta: beta);
            case 'retrieve-call':
              final item = await client.conversations.items.retrieve(
                'conv_shell',
                'shell_0',
              );
              _expectConversationItems([item], [calls[0]], beta: beta);
            case 'retrieve-result':
              final item = await client.conversations.items.retrieve(
                'conv_shell',
                'shell_1',
              );
              _expectConversationItems([item], [calls[1]], beta: beta);
          }
          expect(sends, 1);
        },
      );
    }

    for (final stream in [false, true]) {
      test(
        'typed writable shell history including local skills stream=$stream beta=$beta',
        () async {
          final input = _inputItems(beta: beta);
          final expected = input.map(_normalizeInput).toList();
          final request = CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': input,
          });
          final items = (request.input as ResponseInputItems).items;
          expect(items[0], isA<ShellCallInputItem>());
          expect(items[1], isA<ShellCallOutputInputItem>());
          final local =
              (items[0] as ShellCallInputItem).environment!
                  as LocalShellToolEnvironment;
          expect(local.skills!.single.path, '/synthetic/skills/report');
          expect(local.skills!.clear, throwsUnsupportedError);
          expect(
            (items[0] as ShellCallInputItem).action.commands.clear,
            throwsUnsupportedError,
          );
          expect(
            (items[1] as ShellCallOutputInputItem).output.clear,
            throwsUnsupportedError,
          );
          var sends = 0;
          final client = _client(
            MockClient((httpRequest) async {
              sends++;
              _expectProtocol(httpRequest, beta: beta);
              expect(httpRequest.method, 'POST');
              expect(httpRequest.url.path, '/v1/responses');
              expect(
                httpRequest.url.queryParameters,
                beta ? {'beta': 'true'} : isEmpty,
              );
              expect(jsonDecode(httpRequest.body), {
                'model': 'fixture-model',
                'input': expected,
                if (stream) 'stream': true,
              });
              final response = _responseJson(
                output: _returnedItems(beta: beta),
              );
              return stream
                  ? _sseResponse(_lifecycle(response))
                  : _jsonResponse(response);
            }),
          );
          if (stream) {
            final events = await client.responses
                .createStream(request, beta: beta)
                .toList();
            _expectOutputs(
              (events.last as ResponseCompletedEvent).response.output,
              _returnedItems(beta: beta),
              beta: beta,
            );
          } else {
            final response = await client.responses.create(request, beta: beta);
            _expectOutputs(
              response.output,
              _returnedItems(beta: beta),
              beta: beta,
            );
          }
          expect(request.toJson()['input'], expected);
          expect(sends, 1);
        },
      );
    }

    for (final accumulator in [false, true]) {
      test(
        'public SSE interleaves commands/stdout/stderr and retains final shell metadata accumulator=$accumulator beta=$beta',
        () async {
          final calls = _returnedItems(beta: beta);
          final source = _shellEvents(beta: beta);
          final eventsJson = <Map<String, dynamic>>[
            {
              'type': 'response.created',
              'sequence_number': 0,
              'response': _responseJson(status: 'in_progress'),
            },
            {
              'type': 'response.output_item.added',
              'sequence_number': 1,
              'output_index': 0,
              'item': calls[0],
            },
            {
              'type': 'response.output_item.added',
              'sequence_number': 2,
              'output_index': 1,
              'item': calls[1],
            },
            ...source,
            {
              'type': 'response.output_item.done',
              'sequence_number': 90,
              'output_index': 0,
              'item': calls[0],
            },
            {
              'type': 'response.output_item.done',
              'sequence_number': 91,
              'output_index': 1,
              'item': calls[1],
            },
            {
              'type': 'response.completed',
              'sequence_number': 92,
              'response': _responseJson(output: calls),
            },
          ];
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: beta);
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': 'Describe the commands.',
                'stream': true,
              });
              return _sseResponse(eventsJson);
            }),
          );
          if (accumulator) {
            final snapshots = await client.responses
                .createStreamWithAccumulator(_request(), beta: beta)
                .toList();
            expect(snapshots.last.isSuccessful, isTrue);
            expect(snapshots.last.responseId, 'resp_shell');
            _expectOutputs(snapshots.last.response!.output, calls, beta: beta);
          } else {
            final events = await client.responses
                .createStream(_request(), beta: beta)
                .toList();
            expect(events.whereType<UnknownEvent>(), isEmpty);
            final shell = events
                .where((event) => event.type.startsWith('response.shell_call_'))
                .toList();
            expect(shell.map((event) => event.toJson()).toList(), source);
            final added = shell
                .whereType<ResponseShellCallCommandAddedEvent>()
                .toList();
            expect(
              added
                  .map(
                    (event) =>
                        (event.outputIndex, event.commandIndex, event.command),
                  )
                  .toList(),
              [(0, 0, 'echo '), (0, 1, 'echo ')],
            );
            final delta = shell
                .whereType<ResponseShellCallCommandDeltaEvent>()
                .toList();
            expect(
              delta
                  .map(
                    (event) => (
                      event.outputIndex,
                      event.commandIndex,
                      event.delta,
                      event.obfuscation,
                    ),
                  )
                  .toList(),
              [
                (0, 1, 'second', 'opaque-padding'),
                (0, 0, 'synthetic', null),
                (0, 1, '', null),
              ],
            );
            final done = shell
                .whereType<ResponseShellCallCommandDoneEvent>()
                .toList();
            expect(done.map((event) => event.commandIndex).toList(), [1, 0]);
            expect(done.map((event) => event.command).toList(), [
              'echo second',
              'echo synthetic',
            ]);
            final contentDelta = shell
                .whereType<ResponseShellCallOutputContentDeltaEvent>()
                .toList();
            expect(
              contentDelta
                  .map(
                    (event) =>
                        (event.outputIndex, event.commandIndex, event.itemId),
                  )
                  .toList(),
              [
                (1, 0, 'shell_1'),
                (3, 1, 'shell_3'),
                (1, 0, 'shell_1'),
                (3, 1, 'shell_3'),
              ],
            );
            expect(contentDelta.map((event) => event.delta.toJson()).toList(), [
              {'stdout': 'syn'},
              {'stderr': 'warning'},
              {'stdout': 'thetic', 'stderr': ''},
              <String, dynamic>{},
            ]);
            final contentDone = shell
                .whereType<ResponseShellCallOutputContentDoneEvent>()
                .toList();
            expect(
              contentDone
                  .map(
                    (event) =>
                        (event.outputIndex, event.commandIndex, event.itemId),
                  )
                  .toList(),
              [(3, 1, 'shell_3'), (1, 0, 'shell_1')],
            );
            expect(
              contentDone[0].output.single.outcome,
              isA<ShellCallTimeoutOutcome>(),
            );
            expect(
              contentDone[1].output.single.outcome,
              isA<ShellCallExitOutcome>(),
            );
            expect(contentDone[1].output.single.createdBy, 'content_creator');
            expect(contentDone[1].output.clear, throwsUnsupportedError);
            for (final event in source) {
              if (event['type'].toString().startsWith(
                'response.shell_call_command.',
              )) {
                expect(event.containsKey('item_id'), isFalse);
              }
            }
            _expectOutputs(
              events
                  .whereType<OutputItemAddedEvent>()
                  .map((event) => event.item)
                  .toList(),
              calls.take(2).toList(),
              beta: beta,
            );
            _expectOutputs(
              events
                  .whereType<OutputItemDoneEvent>()
                  .map((event) => event.item)
                  .toList(),
              calls.take(2).toList(),
              beta: beta,
            );
            _expectOutputs(
              (events.last as ResponseCompletedEvent).response.output,
              calls,
              beta: beta,
            );
          }
          expect(sends, 1);
        },
      );
    }

    for (final entry in _malformedReturnedItems().entries) {
      for (final operation in [
        'create',
        'retrieve',
        'list-input',
        'conversation-create',
        'conversation-list',
        'conversation-retrieve',
        'stream',
      ]) {
        test(
          '$operation rejects malformed returned shell ${entry.key} beta=$beta',
          () async {
            final (item, field) = entry.value;
            final client = _client(
              MockClient((request) async {
                _expectProtocol(
                  request,
                  beta: !operation.startsWith('conversation-') && beta,
                );
                return switch (operation) {
                  'stream' => _sseResponse(
                    _lifecycle(_responseJson(output: [item])),
                  ),
                  'list-input' ||
                  'conversation-create' ||
                  'conversation-list' => _jsonResponse(_listJson([item])),
                  'conversation-retrieve' => _jsonResponse(item),
                  _ => _jsonResponse(_responseJson(output: [item])),
                };
              }),
            );
            await expectLater(
              _readMalformed(client, operation, beta: beta),
              _formatError(field),
            );
          },
        );
      }
    }

    for (final itemIndex in [0, 1]) {
      for (final operation in [
        'create',
        'stream',
        'list-input',
        'conversation-retrieve',
      ]) {
        test(
          '$operation handles contextual ${itemIndex == 0 ? 'call' : 'result'} agent null policy beta=$beta',
          () async {
            final item = {
              ..._returnedItems(beta: beta)[itemIndex],
              'agent': null,
            };
            final client = _client(
              MockClient((request) async {
                _expectProtocol(
                  request,
                  beta: !(operation == 'conversation-retrieve') && beta,
                );
                return switch (operation) {
                  'stream' => _sseResponse(
                    _lifecycle(_responseJson(output: [item])),
                  ),
                  'list-input' => _jsonResponse(_listJson([item])),
                  'conversation-retrieve' => _jsonResponse(item),
                  _ => _jsonResponse(_responseJson(output: [item])),
                };
              }),
            );
            if (operation == 'list-input' ||
                operation == 'conversation-retrieve') {
              await expectLater(
                _readMalformed(client, operation, beta: beta),
                _formatError('.agent'),
              );
            } else if (operation == 'stream') {
              final events = await client.responses
                  .createStream(_request(), beta: beta)
                  .toList();
              final output = (events.last as ResponseCompletedEvent)
                  .response
                  .output
                  .single;
              if (itemIndex == 0) {
                expect((output as ShellCallOutputItem).agent, isNull);
              } else {
                expect((output as ShellCallOutputResultItem).agent, isNull);
              }
              expect(output.toJson(), _normalizeReturned(item));
            } else {
              final response = await client.responses.create(
                _request(),
                beta: beta,
              );
              final output = response.output.single;
              if (itemIndex == 0) {
                expect((output as ShellCallOutputItem).agent, isNull);
              } else {
                expect((output as ShellCallOutputResultItem).agent, isNull);
              }
              expect(output.toJson(), _normalizeReturned(item));
            }
          },
        );
      }
    }

    for (final entry in _malformedEvents().entries) {
      for (final accumulator in [false, true]) {
        test(
          'SSE rejects malformed shell event ${entry.key} accumulator=$accumulator beta=$beta',
          () async {
            final (event, field) = entry.value;
            final client = _client(
              MockClient((request) async {
                _expectProtocol(request, beta: beta);
                return _sseResponse([event]);
              }),
            );
            final Future<Object> result = accumulator
                ? client.responses
                      .createStreamWithAccumulator(_request(), beta: beta)
                      .toList()
                : client.responses
                      .createStream(_request(), beta: beta)
                      .toList();
            await expectLater(result, _formatError(field));
          },
        );
      }
    }
  }

  for (final entry in _malformedTools().entries) {
    test(
      'public request parser rejects malformed shell definition ${entry.key}',
      () {
        final (tool, field) = entry.value;
        expect(
          () => CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': 'Describe commands.',
            'tools': [tool],
          }),
          _formatError(field),
        );
      },
    );
  }
  for (final entry in _malformedInputs().entries) {
    test(
      'public request parser rejects malformed writable shell ${entry.key}',
      () {
        final (item, field) = entry.value;
        expect(
          () => CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': [item],
          }),
          _formatError(field),
        );
      },
    );
  }
  test(
    'constructed container_auto input is rejected before either request sends',
    () async {
      var sends = 0;
      final client = _client(
        MockClient((request) async {
          sends++;
          return _jsonResponse(_responseJson());
        }),
      );
      final request = CreateResponseRequest(
        model: 'fixture-model',
        input: ResponseInput.items([
          ShellCallInputItem(
            callId: 'call_bad',
            action: ShellCallActionInput(commands: const ['synthetic']),
            environment: ContainerAutoShellToolEnvironment(),
          ),
        ]),
      );
      await expectLater(client.responses.create(request), throwsArgumentError);
      expect(() => client.responses.createStream(request), throwsArgumentError);
      expect(sends, 0);
    },
  );
}

CreateResponseRequest _request() => const CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.text('Describe the commands.'),
);

Matcher _formatError(String field) => throwsA(
  isA<FormatException>().having(
    (error) => error.message,
    'field context',
    contains(field),
  ),
);

Map<String, (Map<String, dynamic>, Map<String, dynamic>)> _toolCases() {
  final auto = <String, dynamic>{
    'type': 'container_auto',
    'file_ids': ['file-1'],
    'memory_limit': '4g',
    'network_policy': {
      'type': 'allowlist',
      'allowed_domains': ['example.invalid'],
      'domain_secrets': [
        {
          'domain': 'example.invalid',
          'name': 'header',
          'value': 'synthetic-secret',
        },
      ],
    },
    'skills': [
      {'type': 'skill_reference', 'skill_id': 'skill-1', 'version': 'latest'},
      {
        'type': 'inline',
        'name': 'report',
        'description': 'Report formatting',
        'source': {
          'type': 'base64',
          'media_type': 'application/zip',
          'data': 'synthetic-bundle',
        },
      },
    ],
  };
  final local = <String, dynamic>{
    'type': 'local',
    'skills': [
      {
        'name': 'report',
        'description': 'Report formatting',
        'path': '/synthetic/skills/report',
      },
    ],
  };
  const reference = {'type': 'container_reference', 'container_id': 'cntr-1'};
  return {
    'minimal': (const {'type': 'shell'}, const {'type': 'shell'}),
    'nullable settings': (
      const {'type': 'shell', 'environment': null, 'allowed_callers': null},
      const {'type': 'shell'},
    ),
    'empty callers': (
      const {'type': 'shell', 'allowed_callers': <String>[]},
      const {'type': 'shell', 'allowed_callers': <String>[]},
    ),
    'empty auto': (
      const {
        'type': 'shell',
        'environment': {
          'type': 'container_auto',
          'file_ids': <String>[],
          'skills': <Object>[],
          'memory_limit': null,
        },
      },
      const {
        'type': 'shell',
        'environment': {
          'type': 'container_auto',
          'file_ids': <String>[],
          'skills': <Object>[],
        },
      },
    ),
    'empty local skills': (
      const {
        'type': 'shell',
        'environment': {'type': 'local', 'skills': <Object>[]},
      },
      const {
        'type': 'shell',
        'environment': {'type': 'local', 'skills': <Object>[]},
      },
    ),
    for (final environment in [auto, local, reference])
      'full ${environment['type']}': (
        {
          'type': 'shell',
          'environment': environment,
          'allowed_callers': ['direct', 'programmatic'],
        },
        {
          'type': 'shell',
          'environment': environment,
          'allowed_callers': ['direct', 'programmatic'],
        },
      ),
  };
}

List<Map<String, dynamic>> _returnedItems({required bool beta}) => [
  for (var index = 0; index < 6; index++)
    if (index.isEven)
      {
        'type': 'shell_call',
        'id': 'shell_$index',
        'call_id': 'call_${index ~/ 2}',
        'action': {
          'commands': ['echo synthetic-$index', 'echo second-$index'],
          'timeout_ms': index == 0
              ? null
              : index == 2
              ? 0
              : 100,
          'max_output_length': index == 0
              ? null
              : index == 2
              ? 0
              : 10,
        },
        'status': ['in_progress', 'completed', 'incomplete'][index ~/ 2],
        'environment': index == 0
            ? null
            : index == 2
            ? {'type': 'local'}
            : {'type': 'container_reference', 'container_id': 'cntr-1'},
        'caller': index == 0
            ? null
            : index == 2
            ? {'type': 'direct'}
            : {'type': 'program', 'caller_id': 'program-1'},
        'created_by': 'creator_call_$index',
        if (beta) 'agent': {'agent_name': 'shell_worker'},
      }
    else
      {
        'type': 'shell_call_output',
        'id': 'shell_$index',
        'call_id': 'call_${index ~/ 2}',
        'status': ['in_progress', 'completed', 'incomplete'][index ~/ 2],
        'max_output_length': index == 1
            ? null
            : index == 3
            ? 0
            : 10,
        'output': [
          {
            'stdout': 'synthetic output $index',
            'stderr': '',
            'outcome': {'type': 'exit', 'exit_code': index == 1 ? 0 : 2},
            'created_by': 'creator_stdout_$index',
          },
          {
            'stdout': '',
            'stderr': 'synthetic timeout',
            'outcome': {'type': 'timeout'},
            'created_by': 'creator_timeout_$index',
          },
        ],
        'caller': index == 1
            ? null
            : index == 3
            ? {'type': 'direct'}
            : {'type': 'program', 'caller_id': 'program-1'},
        'created_by': 'creator_result_$index',
        if (beta) 'agent': {'agent_name': 'shell_worker'},
      },
];

Map<String, dynamic> _writable(Map<String, dynamic> raw) {
  final json = _clone(raw)..remove('created_by');
  if (json['caller'] == null) json.remove('caller');
  if (json['type'] == 'shell_call') {
    final action = json['action'] as Map<String, dynamic>;
    for (final key in ['timeout_ms', 'max_output_length']) {
      if (action[key] == null) action.remove(key);
    }
    if (json['environment'] == null) json.remove('environment');
  } else {
    if (json['max_output_length'] == null) json.remove('max_output_length');
    for (final output in json['output'] as List) {
      (output as Map).remove('created_by');
    }
  }
  return json;
}

List<Map<String, dynamic>> _inputItems({required bool beta}) => [
  {
    'type': 'shell_call',
    'id': 'input_call',
    'call_id': 'call_local',
    'action': {
      'commands': ['echo synthetic', 'echo second'],
      'timeout_ms': 0,
      'max_output_length': 12,
    },
    'status': 'completed',
    'environment': {
      'type': 'local',
      'skills': [
        {
          'name': 'report',
          'description': 'Report formatting',
          'path': '/synthetic/skills/report',
        },
      ],
    },
    'caller': {'type': 'program', 'caller_id': 'program_local'},
    if (beta) 'agent': {'agent_name': 'shell_worker'},
  },
  {
    'type': 'shell_call_output',
    'id': 'input_result',
    'call_id': 'call_local',
    'status': 'completed',
    'max_output_length': 0,
    'output': [
      {
        'stdout': 'synthetic',
        'stderr': '',
        'outcome': {'type': 'exit', 'exit_code': 0},
        'created_by': 'returned-content-must-drop',
      },
      {
        'stdout': '',
        'stderr': 'synthetic timeout',
        'outcome': {'type': 'timeout'},
      },
    ],
    'caller': {'type': 'direct'},
    'created_by': 'returned-item-must-drop',
    if (beta) 'agent': {'agent_name': 'shell_worker'},
  },
  {
    'type': 'shell_call',
    'call_id': 'call_minimal',
    'action': {
      'commands': <String>[],
      'timeout_ms': null,
      'max_output_length': null,
    },
    'id': null,
    'status': null,
    'environment': null,
    'caller': null,
    'agent': null,
  },
  {
    'type': 'shell_call_output',
    'call_id': 'call_minimal',
    'output': <Object>[],
    'id': null,
    'status': null,
    'max_output_length': null,
    'caller': null,
    'agent': null,
  },
  {
    'type': 'shell_call',
    'call_id': 'call_reference',
    'action': {
      'commands': ['echo reference'],
    },
    'environment': {'type': 'container_reference', 'container_id': 'cntr-1'},
  },
];

Map<String, dynamic> _normalizeInput(Map<String, dynamic> raw) {
  final json = _writable(raw);
  for (final key in [
    'id',
    'status',
    'agent',
    'caller',
    'environment',
    'max_output_length',
  ]) {
    if (json.containsKey(key) && json[key] == null) json.remove(key);
  }
  return json;
}

void _expectOutputs(
  List<OutputItem> items,
  List<Map<String, dynamic>> expected, {
  required bool beta,
}) {
  expect(
    items.map((item) => item.toJson()).toList(),
    expected.map(_normalizeReturned).toList(),
  );
  for (var i = 0; i < items.length; i++) {
    final json = expected[i];
    if (json['type'] == 'shell_call') {
      final call = items[i] as ShellCallOutputItem;
      expect(call.status, ItemStatus.fromJson(json['status'] as String));
      expect(call.agent?.agentName, beta ? 'shell_worker' : null);
      expect(call.createdBy, json['created_by']);
      expect(call.toShellCallInputItem().toJson(), _writable(json));
      expect(call.action.commands.clear, throwsUnsupportedError);
    } else {
      final result = items[i] as ShellCallOutputResultItem;
      expect(result.status, ItemStatus.fromJson(json['status'] as String));
      expect(result.agent?.agentName, beta ? 'shell_worker' : null);
      expect(result.output.first.outcome, isA<ShellCallExitOutcome>());
      expect(result.output.last.outcome, isA<ShellCallTimeoutOutcome>());
      expect(result.createdBy, json['created_by']);
      expect(result.toShellCallOutputInputItem().toJson(), _writable(json));
      expect(result.output.clear, throwsUnsupportedError);
    }
  }
}

void _expectConversationItems(
  List<ConversationItem> items,
  List<Map<String, dynamic>> expected, {
  required bool beta,
}) {
  expect(
    items.map((item) => item.toJson()).toList(),
    expected.map(_normalizeReturned).toList(),
  );
  for (var i = 0; i < items.length; i++) {
    if (expected[i]['type'] == 'shell_call') {
      final call = items[i] as ConversationShellCallItem;
      expect(call.agent?.agentName, beta ? 'shell_worker' : null);
      expect(call.toShellCallInputItem().toJson(), _writable(expected[i]));
    } else {
      final result = items[i] as ConversationShellCallOutputItem;
      expect(result.agent?.agentName, beta ? 'shell_worker' : null);
      expect(
        result.toShellCallOutputInputItem().toJson(),
        _writable(expected[i]),
      );
      expect(result.output.first.outcome, isA<ShellCallExitOutcome>());
      expect(result.output.last.outcome, isA<ShellCallTimeoutOutcome>());
    }
  }
}

List<Map<String, dynamic>> _shellEvents({required bool beta}) {
  Map<String, dynamic> event(
    String type,
    int sequence,
    int output,
    int command,
    Map<String, dynamic> payload,
  ) => {
    'type': type,
    'sequence_number': sequence,
    'output_index': output,
    'command_index': command,
    ...payload,
    if (beta) 'agent': {'agent_name': 'shell_worker'},
  };
  return [
    event('response.shell_call_command.added', 3, 0, 0, {'command': 'echo '}),
    event('response.shell_call_command.added', 4, 0, 1, {'command': 'echo '}),
    event('response.shell_call_command.delta', 5, 0, 1, {
      'delta': 'second',
      'obfuscation': 'opaque-padding',
    }),
    event('response.shell_call_command.delta', 6, 0, 0, {'delta': 'synthetic'}),
    event('response.shell_call_command.delta', 7, 0, 1, {'delta': ''}),
    event('response.shell_call_command.done', 8, 0, 1, {
      'command': 'echo second',
    }),
    event('response.shell_call_command.done', 9, 0, 0, {
      'command': 'echo synthetic',
    }),
    event('response.shell_call_output_content.delta', 10, 1, 0, {
      'item_id': 'shell_1',
      'delta': {'stdout': 'syn'},
    }),
    event('response.shell_call_output_content.delta', 11, 3, 1, {
      'item_id': 'shell_3',
      'delta': {'stderr': 'warning'},
    }),
    event('response.shell_call_output_content.delta', 12, 1, 0, {
      'item_id': 'shell_1',
      'delta': {'stdout': 'thetic', 'stderr': ''},
    }),
    event('response.shell_call_output_content.delta', 13, 3, 1, {
      'item_id': 'shell_3',
      'delta': <String, dynamic>{},
    }),
    event('response.shell_call_output_content.done', 14, 3, 1, {
      'item_id': 'shell_3',
      'output': [
        {
          'stdout': '',
          'stderr': 'warning',
          'outcome': {'type': 'timeout'},
        },
      ],
    }),
    event('response.shell_call_output_content.done', 15, 1, 0, {
      'item_id': 'shell_1',
      'output': [
        {
          'stdout': 'synthetic',
          'stderr': '',
          'outcome': {'type': 'exit', 'exit_code': 0},
          'created_by': 'content_creator',
        },
      ],
    }),
  ];
}

Map<String, (Map<String, dynamic>, String)> _malformedReturnedItems() {
  final call = _returnedItems(beta: false)[0];
  final result = _returnedItems(beta: false)[1];
  Map<String, dynamic> action(Map<String, dynamic> update) => {
    ...call,
    'action': {...(call['action'] as Map<String, dynamic>), ...update},
  };
  Map<String, dynamic> chunk(Map<String, dynamic> update) => {
    ...result,
    'output': [
      {...((result['output'] as List)[0] as Map<String, dynamic>), ...update},
    ],
  };
  return {
    for (final field in ['id', 'call_id', 'status', 'environment'])
      'missing call $field': (_clone(call)..remove(field), '.$field'),
    for (final field in ['timeout_ms', 'max_output_length'])
      'missing returned action $field': (
        {
          ...call,
          'action': _clone(call['action'] as Map<String, dynamic>)
            ..remove(field),
        },
        '.action.$field',
      ),
    for (final field in [
      'id',
      'call_id',
      'status',
      'output',
      'max_output_length',
    ])
      'missing result $field': (_clone(result)..remove(field), '.$field'),
    'fractional returned timeout': (
      action({'timeout_ms': 1.5}),
      '.action.timeout_ms',
    ),
    'bad command element': (
      action({
        'commands': [null],
      }),
      '.action.commands[0]',
    ),
    'invalid returned auto': (
      {
        ...call,
        'environment': {'type': 'container_auto'},
      },
      '.environment.type',
    ),
    'missing reference ID': (
      {
        ...call,
        'environment': {'type': 'container_reference'},
      },
      '.environment.container_id',
    ),
    'null creator': ({...call, 'created_by': null}, '.created_by'),
    'null result creator': ({...result, 'created_by': null}, '.created_by'),
    'null chunk creator': (
      chunk({'created_by': null}),
      '.output[0].created_by',
    ),
    'missing exit code': (
      chunk({
        'outcome': {'type': 'exit'},
      }),
      '.output[0].outcome.exit_code',
    ),
    'null stdout': (chunk({'stdout': null}), '.output[0].stdout'),
    'missing program caller ID': (
      {
        ...call,
        'caller': {'type': 'program'},
      },
      '.caller.caller_id',
    ),
    'invalid agent name': (
      {
        ...call,
        'agent': {'agent_name': null},
      },
      '.agent.agent_name',
    ),
  };
}

Map<String, (Map<String, dynamic>, String)> _malformedEvents() {
  final cases = <String, (Map<String, dynamic>, String)>{};
  final sources = _shellEvents(beta: false);
  for (final type in [
    'response.shell_call_command.added',
    'response.shell_call_command.delta',
    'response.shell_call_command.done',
    'response.shell_call_output_content.delta',
    'response.shell_call_output_content.done',
  ]) {
    final event = sources.firstWhere((event) => event['type'] == type);
    for (final field in [
      'sequence_number',
      'output_index',
      'command_index',
      if (type.contains('output_content')) 'item_id',
      if (type.endsWith('.delta'))
        'delta'
      else if (type.contains('command.'))
        'command'
      else
        'output',
    ]) {
      cases['$type missing $field'] = (_clone(event)..remove(field), '.$field');
    }
    cases['$type null agent'] = ({...event, 'agent': null}, '.agent');
  }
  final command = sources.firstWhere(
    (event) => event['type'] == 'response.shell_call_command.delta',
  );
  cases['null obfuscation'] = (
    {...command, 'obfuscation': null},
    '.obfuscation',
  );
  final delta = sources.firstWhere(
    (event) => event['type'] == 'response.shell_call_output_content.delta',
  );
  for (final field in ['stdout', 'stderr']) {
    cases['null output delta $field'] = (
      {
        ...delta,
        'delta': {field: null},
      },
      '.delta.$field',
    );
  }
  final done = sources.firstWhere(
    (event) => event['type'] == 'response.shell_call_output_content.done',
  );
  cases['malformed output done outcome'] = (
    {
      ...done,
      'output': [
        {
          'stdout': '',
          'stderr': '',
          'outcome': {'type': 'exit', 'exit_code': 'bad'},
        },
      ],
    },
    '.output[0].outcome.exit_code',
  );
  return cases;
}

Map<String, (Map<String, dynamic>, String)> _malformedTools() => {
  'null auto files': (
    {
      'type': 'shell',
      'environment': {'type': 'container_auto', 'file_ids': null},
    },
    'file_ids',
  ),
  'null auto network': (
    {
      'type': 'shell',
      'environment': {'type': 'container_auto', 'network_policy': null},
    },
    'network_policy',
  ),
  'null auto skills': (
    {
      'type': 'shell',
      'environment': {'type': 'container_auto', 'skills': null},
    },
    'skills',
  ),
  'null local skills': (
    {
      'type': 'shell',
      'environment': {'type': 'local', 'skills': null},
    },
    'skills',
  ),
  'missing local skill path': (
    {
      'type': 'shell',
      'environment': {
        'type': 'local',
        'skills': [
          {'name': 'n', 'description': 'd'},
        ],
      },
    },
    'skills[0]',
  ),
  'missing hosted skill ID': (
    {
      'type': 'shell',
      'environment': {
        'type': 'container_auto',
        'skills': [
          {'type': 'skill_reference'},
        ],
      },
    },
    'skills[0]',
  ),
};

Map<String, (Map<String, dynamic>, String)> _malformedInputs() {
  final call = _inputItems(beta: false)[0];
  final result = _inputItems(beta: false)[1];
  return {
    'auto call environment': (
      {
        ...call,
        'environment': {'type': 'container_auto'},
      },
      '.environment.type',
    ),
    'null local skills': (
      {
        ...call,
        'environment': {'type': 'local', 'skills': null},
      },
      'skills',
    ),
    'invalid local skill path': (
      {
        ...call,
        'environment': {
          'type': 'local',
          'skills': [
            {'name': 'n', 'description': 'd', 'path': null},
          ],
        },
      },
      'path',
    ),
    'missing call ID': (_clone(call)..remove('call_id'), '.call_id'),
    'null commands': (
      {
        ...call,
        'action': {'commands': null},
      },
      '.action.commands',
    ),
    'fractional request timeout': (
      {
        ...call,
        'action': {'commands': <String>[], 'timeout_ms': 1.5},
      },
      '.action.timeout_ms',
    ),
    'null output': ({...result, 'output': null}, '.output'),
    'missing output stderr': (
      {
        ...result,
        'output': [
          {
            'stdout': '',
            'outcome': {'type': 'timeout'},
          },
        ],
      },
      '.output[0].stderr',
    ),
  };
}

Future<Object> _readMalformed(
  OpenAIClient client,
  String operation, {
  required bool beta,
}) => switch (operation) {
  'create' => client.responses.create(_request(), beta: beta),
  'retrieve' => client.responses.retrieve('resp_shell', beta: beta),
  'list-input' => client.responses.inputItems.list('resp_shell', beta: beta),
  'conversation-create' => client.conversations.items.create(
    'conv_shell',
    const ItemsCreateRequest(items: []),
  ),
  'conversation-list' => client.conversations.items.list('conv_shell'),
  'conversation-retrieve' => client.conversations.items.retrieve(
    'conv_shell',
    'shell_bad',
  ),
  _ => client.responses.createStream(_request(), beta: beta).toList(),
};

Map<String, dynamic> _clone(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

Map<String, dynamic> _normalizeReturned(Map<String, dynamic> raw) {
  final json = _clone(raw);
  for (final field in ['caller', 'agent']) {
    if (json.containsKey(field) && json[field] == null) json.remove(field);
  }
  return json;
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

void _expectProtocol(http.Request request, {required bool beta}) {
  expect(request.headers['Authorization'], 'Bearer fixture-key');
  expect(
    request.headers['OpenAI-Beta'],
    beta ? 'responses_multi_agent=v1' : null,
  );
}

Map<String, dynamic> _responseJson({
  List<Map<String, dynamic>> output = const [],
  List<Map<String, dynamic>> tools = const [],
  String status = 'completed',
}) => {
  'id': 'resp_shell',
  'object': 'response',
  'created_at': 1700000000,
  'status': status,
  'model': 'fixture-model',
  'output': output,
  'tools': tools,
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'parallel_tool_calls': false,
  'metadata': <String, dynamic>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};

Map<String, dynamic> _listJson(List<Map<String, dynamic>> items) => {
  'object': 'list',
  'data': items,
  'has_more': false,
  'first_id': items.first['id'],
  'last_id': items.last['id'],
};

List<Map<String, dynamic>> _lifecycle(Map<String, dynamic> response) {
  final output = response['output'] as List<Map<String, dynamic>>;
  var sequence = 0;
  return [
    {
      'type': 'response.created',
      'sequence_number': sequence++,
      'response': {...response, 'status': 'in_progress', 'output': <Object>[]},
    },
    for (var i = 0; i < output.length; i++) ...[
      {
        'type': 'response.output_item.added',
        'sequence_number': sequence++,
        'output_index': i,
        'item': output[i],
      },
      {
        'type': 'response.output_item.done',
        'sequence_number': sequence++,
        'output_index': i,
        'item': output[i],
      },
    ],
    {
      'type': 'response.completed',
      'sequence_number': sequence++,
      'response': response,
    },
  ];
}

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
