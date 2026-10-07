import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final includes = <Include>[
    Include.webSearchResults,
    Include.webSearchActionSources,
    Include.messageInputImageImageUrl,
    Include.computerCallOutputImageUrl,
    Include.reasoningEncryptedContent,
    Include.messageOutputTextLogprobs,
    Include.fileSearchResults,
    Include.codeInterpreterOutputs,
    Include.messageInputAudioTranscript,
    Include.computerCallOutputs,
  ];
  const includeJson = [
    'web_search_call.results',
    'web_search_call.action.sources',
    'message.input_image.image_url',
    'computer_call_output.output.image_url',
    'reasoning.encrypted_content',
    'message.output_text.logprobs',
    'file_search_call.results',
    'code_interpreter_call.outputs',
    'message.input_audio.transcription',
    'computer_call.outputs',
  ];

  for (final entry in _toolCases().entries) {
    for (final beta in [false, true]) {
      for (final operation in ['create', 'stream', 'retrieve']) {
        test('$operation preserves ${entry.key} beta=$beta', () async {
          final (input, expected) = entry.value;
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: beta);
              expect(request.method, operation == 'retrieve' ? 'GET' : 'POST');
              expect(
                request.url.path,
                operation == 'retrieve'
                    ? '/v1/responses/resp_web'
                    : '/v1/responses',
              );
              expect(
                request.url.queryParameters,
                beta ? {'beta': 'true'} : isEmpty,
              );
              if (operation != 'retrieve') {
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': 'Find a relevant image.',
                  'tools': [expected],
                  if (operation == 'stream') 'stream': true,
                });
              }
              final response = _responseJson(
                tools: [expected],
                output: [
                  {
                    'type': 'additional_tools',
                    'id': 'additional_web',
                    'role': 'developer',
                    'tools': [expected],
                    if (beta) 'agent': {'agent_name': 'web_worker'},
                  },
                ],
              );
              return operation == 'stream'
                  ? _sseResponse(_events(response))
                  : _jsonResponse(response);
            }),
          );
          final request = CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': 'Find a relevant image.',
            'tools': [input],
          });
          expect(request.tools!.single, isA<WebSearchTool>());
          final Response response;
          if (operation == 'retrieve') {
            response = await client.responses.retrieve('resp_web', beta: beta);
          } else if (operation == 'stream') {
            final events = await client.responses
                .createStream(request, beta: beta)
                .toList();
            expect(events.whereType<UnknownEvent>(), isEmpty);
            response = (events.last as ResponseCompletedEvent).response;
          } else {
            response = await client.responses.create(request, beta: beta);
          }
          final returned = response.output.single as AdditionalToolsOutputItem;
          expect(returned.tools.single, isA<WebSearchTool>());
          expect(returned.tools.single.toJson(), expected);
          expect(returned.agent?.agentName, beta ? 'web_worker' : null);
          expect(sends, 1);
        });
      }
    }
  }

  for (final beta in [false, true]) {
    for (final operation in ['create', 'stream', 'retrieve', 'list-input']) {
      test(
        '$operation sends every canonical and legacy include beta=$beta',
        () async {
          var sends = 0;
          final calls = _calls(beta: beta);
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: beta);
              if (operation == 'retrieve' || operation == 'list-input') {
                expect(request.method, 'GET');
                expect(
                  request.url.path,
                  operation == 'retrieve'
                      ? '/v1/responses/resp_web'
                      : '/v1/responses/resp_web/input_items',
                );
                expect(request.url.queryParametersAll, {
                  'include[]': includeJson,
                  if (operation == 'list-input') ...{
                    'after': ['ws_before'],
                    'before': ['ws_after'],
                    'limit': ['25'],
                    'order': ['desc'],
                  },
                  if (beta) 'beta': ['true'],
                });
              } else {
                expect(request.method, 'POST');
                expect(request.url.path, '/v1/responses');
                expect(jsonDecode(request.body), {
                  'model': 'fixture-model',
                  'input': 'Find sources.',
                  'include': includeJson,
                  if (operation == 'stream') 'stream': true,
                });
              }
              final response = _responseJson(output: calls);
              return switch (operation) {
                'stream' => _sseResponse(_events(response)),
                'list-input' => _jsonResponse(_listJson(calls)),
                _ => _jsonResponse(response),
              };
            }),
          );
          final request = CreateResponseRequest(
            model: 'fixture-model',
            input: const ResponseInput.text('Find sources.'),
            include: includes,
          );
          switch (operation) {
            case 'create':
              final response = await client.responses.create(
                request,
                beta: beta,
              );
              _expectOutputCalls(response.output, calls);
            case 'stream':
              final events = await client.responses
                  .createStream(request, beta: beta)
                  .toList();
              final response = (events.last as ResponseCompletedEvent).response;
              _expectOutputCalls(response.output, calls);
            case 'retrieve':
              final response = await client.responses.retrieve(
                'resp_web',
                include: includes,
                beta: beta,
              );
              _expectOutputCalls(response.output, calls);
            case 'list-input':
              final page = await client.responses.inputItems.list(
                'resp_web',
                after: 'ws_before',
                before: 'ws_after',
                limit: 25,
                order: 'desc',
                include: includes,
                beta: beta,
              );
              expect(page.data, everyElement(isA<WebSearchCallItem>()));
              expect(page.data.map((item) => item.toJson()).toList(), calls);
              final call = page.data.first as WebSearchCallItem;
              expect(call.status, WebSearchCallStatus.inProgress);
              expect(call.action, isA<WebSearchActionSearch>());
              expect(call.results!.first, isA<WebSearchImageResult>());
              expect(call.agent?.agentName, beta ? 'web_worker' : null);
          }
          expect(sends, 1);
        },
      );
    }

    for (final operation in ['retrieve', 'list-input']) {
      for (final empty in [false, true]) {
        test(
          '$operation omits absent or empty includes empty=$empty beta=$beta',
          () async {
            var sends = 0;
            final client = _client(
              MockClient((request) async {
                sends++;
                _expectProtocol(request, beta: beta);
                expect(request.method, 'GET');
                expect(
                  request.url.queryParametersAll,
                  beta
                      ? {
                          'beta': ['true'],
                        }
                      : isEmpty,
                );
                return _jsonResponse(
                  operation == 'retrieve'
                      ? _responseJson()
                      : _listJson([_calls(beta: beta).first]),
                );
              }),
            );
            if (operation == 'retrieve') {
              final response = await client.responses.retrieve(
                'resp_web',
                include: empty ? [] : null,
                beta: beta,
              );
              expect(response.id, 'resp_web');
            } else {
              final page = await client.responses.inputItems.list(
                'resp_web',
                include: empty ? [] : null,
                beta: beta,
              );
              expect(page.data.single, isA<WebSearchCallItem>());
            }
            expect(sends, 1);
          },
        );
      }
    }

    for (final accumulator in [false, true]) {
      test(
        'SSE call actions/results reach ${accumulator ? 'accumulator' : 'events'} beta=$beta',
        () async {
          final calls = _calls(beta: beta);
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              _expectProtocol(request, beta: beta);
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': 'Find sources.',
                'include': includeJson,
                'stream': true,
              });
              return _sseResponse(_events(_responseJson(output: calls)));
            }),
          );
          final request = CreateResponseRequest(
            model: 'fixture-model',
            input: const ResponseInput.text('Find sources.'),
            include: includes,
          );
          if (accumulator) {
            final snapshots = await client.responses
                .createStreamWithAccumulator(request, beta: beta)
                .toList();
            expect(snapshots.last.isSuccessful, isTrue);
            expect(snapshots.last.responseId, 'resp_web');
            _expectOutputCalls(snapshots.last.response!.output, calls);
          } else {
            final events = await client.responses
                .createStream(request, beta: beta)
                .toList();
            final added = events.whereType<OutputItemAddedEvent>().toList();
            final done = events.whereType<OutputItemDoneEvent>().toList();
            _expectOutputCalls(
              added.map((event) => event.item).toList(),
              calls,
            );
            _expectOutputCalls(done.map((event) => event.item).toList(), calls);
            _expectOutputCalls(
              (events.last as ResponseCompletedEvent).response.output,
              calls,
            );
            expect(events.whereType<UnknownEvent>(), isEmpty);
          }
          expect(sends, 1);
        },
      );
    }

    for (final operation in [
      'conversation-create',
      'create',
      'list',
      'retrieve',
    ]) {
      test(
        'conversation $operation preserves actions/results and beta metadata=$beta',
        () async {
          final calls = _calls(beta: beta);
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              expect(request.headers['Authorization'], 'Bearer fixture-key');
              expect(request.headers['OpenAI-Beta'], isNull);
              if (operation == 'conversation-create') {
                expect(request.method, 'POST');
                expect(request.url.path, '/v1/conversations');
                expect(jsonDecode(request.body), {'items': calls});
                return _jsonResponse({
                  'id': 'conv_web',
                  'object': 'conversation',
                  'created_at': 1700000000,
                  'metadata': <String, dynamic>{},
                });
              }
              expect(request.method, operation == 'create' ? 'POST' : 'GET');
              expect(
                request.url.path,
                operation == 'retrieve'
                    ? '/v1/conversations/conv_web/items/ws_0'
                    : '/v1/conversations/conv_web/items',
              );
              if (operation == 'create') {
                expect(jsonDecode(request.body), {'items': calls});
              }
              if (operation == 'list') {
                expect(request.url.queryParameters, {
                  'limit': '25',
                  'order': 'asc',
                });
              }
              return _jsonResponse(
                operation == 'retrieve' ? calls.first : _listJson(calls),
              );
            }),
          );
          switch (operation) {
            case 'conversation-create':
              final conversation = await client.conversations.create(
                ConversationCreateRequest(
                  items: calls.map(Item.fromResourceJson).toList(),
                ),
              );
              expect(conversation.id, 'conv_web');
            case 'create':
              final page = await client.conversations.items.create(
                'conv_web',
                ItemsCreateRequest(
                  items: calls.map(Item.fromResourceJson).toList(),
                ),
              );
              _expectConversationCalls(page.data, calls);
            case 'list':
              final page = await client.conversations.items.list(
                'conv_web',
                limit: 25,
                order: 'asc',
              );
              _expectConversationCalls(page.data, calls);
            case 'retrieve':
              final item = await client.conversations.items.retrieve(
                'conv_web',
                'ws_0',
              );
              _expectConversationCalls([item], [calls.first]);
          }
          expect(sends, 1);
        },
      );
    }
  }

  for (final beta in [false, true]) {
    for (final stream in [false, true]) {
      test(
        'public request reuses typed web history stream=$stream beta=$beta',
        () async {
          final calls = _calls(beta: beta);
          final input = <Map<String, dynamic>>[
            ...calls,
            {
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Compare those sources.'},
              ],
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
                'input': input,
                if (stream) 'stream': true,
              });
              final response = _responseJson(output: calls);
              return stream
                  ? _sseResponse(_events(response))
                  : _jsonResponse(response);
            }),
          );
          final request = CreateResponseRequest.fromJson({
            'model': 'fixture-model',
            'input': input,
          });
          final items = (request.input as ResponseInputItems).items;
          expect(
            items.take(calls.length),
            everyElement(isA<WebSearchCallItem>()),
          );
          final first = items.first as WebSearchCallItem;
          expect(first.action, isA<WebSearchActionSearch>());
          expect(first.results!.first, isA<WebSearchImageResult>());
          if (stream) {
            final events = await client.responses
                .createStream(request, beta: beta)
                .toList();
            _expectOutputCalls(
              (events.last as ResponseCompletedEvent).response.output,
              calls,
            );
          } else {
            final response = await client.responses.create(request, beta: beta);
            _expectOutputCalls(response.output, calls);
          }
          expect(sends, 1);
        },
      );
    }

    for (final status in ['absent', 'null', 'future_status']) {
      for (final operation in [
        'create',
        'list-input',
        'conversation-retrieve',
      ]) {
        test(
          '$operation retains provider tolerance status=$status beta=$beta',
          () async {
            final raw = <String, dynamic>{
              'type': 'web_search_call',
              'id': 'ws_tolerated',
              if (status != 'absent')
                'status': status == 'null' ? null : status,
              'agent': null,
              'action': {'type': 'open_page', 'url': null},
              'results': [
                {
                  'type': 'image_result',
                  'image_url': 'https://image.example/image.png',
                  'source_website_url': 'https://source.example',
                  'thumbnail_url': null,
                  'caption': null,
                },
              ],
            };
            final expected = <String, dynamic>{
              'type': 'web_search_call',
              'id': 'ws_tolerated',
              if (status == 'future_status') 'status': 'unknown',
              'action': {'type': 'open_page'},
              'results': [
                {
                  'type': 'image_result',
                  'image_url': 'https://image.example/image.png',
                  'source_website_url': 'https://source.example',
                },
              ],
            };
            var sends = 0;
            final client = _client(
              MockClient((request) async {
                sends++;
                if (operation != 'conversation-retrieve') {
                  _expectProtocol(request, beta: beta);
                }
                return _jsonResponse(switch (operation) {
                  'create' => _responseJson(output: [raw]),
                  'list-input' => _listJson([raw]),
                  _ => raw,
                });
              }),
            );
            switch (operation) {
              case 'create':
                final response = await client.responses.create(
                  const CreateResponseRequest(
                    model: 'fixture-model',
                    input: ResponseInput.text('Search.'),
                  ),
                  beta: beta,
                );
                expect(response.output.single.toJson(), expected);
                final call = response.output.single as WebSearchCallOutputItem;
                expect(call.action, isA<WebSearchActionOpenPage>());
                expect(call.results!.single, isA<WebSearchImageResult>());
              case 'list-input':
                final page = await client.responses.inputItems.list(
                  'resp_web',
                  beta: beta,
                );
                expect(page.data.single, isA<WebSearchCallItem>());
                expect(page.data.single.toJson(), expected);
              case 'conversation-retrieve':
                final item = await client.conversations.items.retrieve(
                  'conv_web',
                  'ws_tolerated',
                );
                expect(item, isA<ConversationWebSearchCallItem>());
                expect(item.toJson(), expected);
            }
            expect(sends, 1);
          },
        );
      }
    }
  }

  for (final entry in _malformedCalls().entries) {
    for (final operation in ['create', 'conversation-retrieve']) {
      test(
        '$operation rejects malformed ${entry.key} with nested context',
        () async {
          var sends = 0;
          final (call, field) = entry.value;
          final client = _client(
            MockClient((_) async {
              sends++;
              return _jsonResponse(
                operation == 'create' ? _responseJson(output: [call]) : call,
              );
            }),
          );
          final Future<Object> result = operation == 'create'
              ? client.responses.create(
                  const CreateResponseRequest(
                    model: 'fixture-model',
                    input: ResponseInput.text('Search.'),
                  ),
                )
              : client.conversations.items.retrieve('conv_web', 'ws_bad');
          await expectLater(
            result,
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'field',
                contains(field),
              ),
            ),
          );
          expect(sends, 1);
        },
      );
    }
  }

  for (final operation in [
    'retrieve',
    'list-input',
    'conversation-create',
    'conversation-list',
    'stream',
    'accumulator',
  ]) {
    test(
      '$operation rejects a malformed known image instead of hiding it',
      () async {
        final call = <String, dynamic>{
          'type': 'web_search_call',
          'id': 'ws_bad',
          'status': 'completed',
          'results': [
            {
              'type': 'image_result',
              'source_website_url': 'https://source.example',
            },
          ],
        };
        var sends = 0;
        final client = _client(
          MockClient((_) async {
            sends++;
            if (operation == 'stream' || operation == 'accumulator') {
              return _sseResponse(_events(_responseJson(output: [call])));
            }
            return _jsonResponse(
              operation == 'retrieve'
                  ? _responseJson(output: [call])
                  : _listJson([call]),
            );
          }),
        );
        final Future<Object> result = switch (operation) {
          'retrieve' => client.responses.retrieve('resp_web'),
          'list-input' => client.responses.inputItems.list('resp_web'),
          'conversation-create' => client.conversations.items.create(
            'conv_web',
            const ItemsCreateRequest(items: []),
          ),
          'conversation-list' => client.conversations.items.list('conv_web'),
          'stream' =>
            client.responses
                .createStream(
                  const CreateResponseRequest(
                    model: 'fixture-model',
                    input: ResponseInput.text('Search.'),
                  ),
                )
                .toList(),
          _ =>
            client.responses
                .createStreamWithAccumulator(
                  const CreateResponseRequest(
                    model: 'fixture-model',
                    input: ResponseInput.text('Search.'),
                  ),
                )
                .toList(),
        };
        await expectLater(
          result,
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'field',
              contains('results[0].image_url'),
            ),
          ),
        );
        expect(sends, 1);
      },
    );
  }

  for (final entry in _malformedTools().entries) {
    test('public request parser rejects malformed tool ${entry.key}', () {
      final (tool, field) = entry.value;
      expect(
        () => CreateResponseRequest.fromJson({
          'model': 'fixture-model',
          'input': 'Search.',
          'tools': [tool],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'field',
            contains(field),
          ),
        ),
      );
    });
  }

  test(
    'public default uses GA while explicit preview tool choice is preserved',
    () async {
      var sends = 0;
      final client = _client(
        MockClient((request) async {
          sends++;
          expect(jsonDecode(request.body), {
            'model': 'fixture-model',
            'input': 'Search.',
            'tools': [
              {'type': sends == 1 ? 'web_search' : 'web_search_preview'},
            ],
            'tool_choice': {
              'type': sends == 1 ? 'web_search' : 'web_search_preview',
            },
          });
          return _jsonResponse(_responseJson());
        }),
      );
      for (final type in ['web_search', 'web_search_preview']) {
        await client.responses.create(
          CreateResponseRequest(
            model: 'fixture-model',
            input: const ResponseInput.text('Search.'),
            tools: [
              if (type == 'web_search')
                ResponseTool.webSearch()
              else
                ResponseTool.webSearch(type: type),
            ],
            toolChoice: ResponseToolChoice.fromJson({'type': type}),
          ),
        );
      }
      expect(sends, 2);
    },
  );
}

Map<String, (Map<String, dynamic>, Map<String, dynamic>)> _toolCases() {
  final cases = <String, (Map<String, dynamic>, Map<String, dynamic>)>{};
  for (final type in [
    'web_search',
    'web_search_2025_08_26',
    'web_search_preview',
    'web_search_preview_2025_03_11',
  ]) {
    final minimal = <String, dynamic>{'type': type};
    cases['$type omitted controls'] = (minimal, minimal);
    cases['$type nullable location'] = (
      {'type': type, 'user_location': null},
      minimal,
    );
    cases['$type empty location'] = (
      {'type': type, 'user_location': <String, dynamic>{}},
      {
        'type': type,
        'user_location': {'type': 'approximate'},
      },
    );
    if (type.startsWith('web_search_preview')) {
      final preview = <String, dynamic>{
        'type': type,
        'search_context_size': 'low',
        'user_location': {
          'type': 'approximate',
          'city': 'Paris',
          'country': 'FR',
        },
        'search_content_types': ['text', 'image'],
      };
      cases['$type explicit compatibility'] = (preview, preview);
      continue;
    }
    final empty = <String, dynamic>{
      'type': type,
      'external_web_access': false,
      'filters': {'allowed_domains': <String>[], 'blocked_domains': <String>[]},
      'search_content_types': <String>[],
      'image_settings': <String, dynamic>{},
    };
    cases['$type false and empty controls'] = (empty, empty);
    cases['$type empty filters'] = (
      {'type': type, 'filters': <String, dynamic>{}},
      {'type': type, 'filters': <String, dynamic>{}},
    );
    cases['$type nullable filters and location fields'] = (
      {
        'type': type,
        'filters': null,
        'user_location': {
          'type': 'approximate',
          'city': null,
          'country': null,
          'region': null,
          'timezone': null,
        },
      },
      {
        'type': type,
        'user_location': {'type': 'approximate'},
      },
    );
    cases['$type nullable domain lists'] = (
      {
        'type': type,
        'filters': {'allowed_domains': null, 'blocked_domains': null},
      },
      {'type': type, 'filters': <String, dynamic>{}},
    );
    final full = <String, dynamic>{
      'type': type,
      'external_web_access': true,
      'search_context_size': 'high',
      'filters': {
        'allowed_domains': ['docs.example'],
        'blocked_domains': ['ads.example'],
      },
      'user_location': {
        'type': 'approximate',
        'country': 'US',
        'region': 'CA',
        'city': 'San Francisco',
        'timezone': 'America/Los_Angeles',
      },
      'return_token_budget': 'unlimited',
      'search_content_types': ['text', 'image'],
      'image_settings': {'max_results': 3, 'caption': false},
    };
    cases['$type complete guide controls'] = (full, full);
    final defaults = <String, dynamic>{
      'type': type,
      'return_token_budget': 'default',
      'image_settings': {'caption': true},
    };
    cases['$type explicit default budget and caption'] = (defaults, defaults);
  }
  return cases;
}

List<Map<String, dynamic>> _calls({required bool beta}) {
  const image = <String, dynamic>{
    'type': 'image_result',
    'image_url': 'https://images.example/photo.png',
    'source_website_url': 'https://source.example/article',
    'thumbnail_url': 'https://images.example/thumb.png',
    'caption': 'A useful reference image.',
  };
  final variants = <Map<String, dynamic>>[
    for (final status in [
      'in_progress',
      'searching',
      'completed',
      'failed',
      'incomplete',
    ])
      {
        'status': status,
        'action': {
          'type': 'search',
          'queries': ['first query', 'second query'],
          'query': 'legacy query',
          'sources': [
            {'type': 'url', 'url': 'https://source.example/article'},
          ],
        },
        'results': [image],
      },
    {'status': 'completed'},
    {
      'status': 'completed',
      'action': {
        'type': 'search',
        'queries': <String>[],
        'sources': <Object>[],
      },
      'results': <Object>[],
    },
    {
      'status': 'completed',
      'action': {'type': 'search', 'query': 'legacy only'},
    },
    {
      'status': 'completed',
      'action': {'type': 'open_page', 'url': 'https://source.example/article'},
    },
    {
      'status': 'completed',
      'action': {'type': 'open_page'},
    },
    {
      'status': 'completed',
      'action': {
        'type': 'find_in_page',
        'url': 'https://source.example/article',
        'pattern': 'database',
      },
    },
    {
      'status': 'completed',
      'action': {
        'type': 'future_action',
        'payload': {
          'nested': [
            1,
            {'private': 'value'},
          ],
        },
      },
      'results': [
        {
          'type': 'future_result',
          'payload': {
            'nested': [
              1,
              {'private': 'value'},
            ],
          },
        },
      ],
    },
    {
      'status': 'completed',
      'results': [
        {
          'type': 'image_result',
          'image_url': 'https://images.example/photo.png',
          'source_website_url': 'https://source.example/article',
        },
      ],
    },
  ];
  return [
    for (var i = 0; i < variants.length; i++)
      {
        'type': 'web_search_call',
        'id': 'ws_$i',
        ...variants[i],
        if (beta) 'agent': {'agent_name': 'web_worker'},
      },
  ];
}

void _expectOutputCalls(
  List<OutputItem> items,
  List<Map<String, dynamic>> expected,
) {
  expect(items, everyElement(isA<WebSearchCallOutputItem>()));
  expect(items.map((item) => item.toJson()).toList(), expected);
  final calls = items.cast<WebSearchCallOutputItem>();
  expect(calls.take(5).map((item) => item.status!.toJson()), [
    'in_progress',
    'searching',
    'completed',
    'failed',
    'incomplete',
  ]);
  expect(calls.first.action, isA<WebSearchActionSearch>());
  expect(calls.first.results!.first, isA<WebSearchImageResult>());
  if (items.length > 10) {
    expect(calls[8].action, isA<WebSearchActionOpenPage>());
    expect(calls[10].action, isA<WebSearchActionFind>());
    expect(calls[11].action, isA<UnknownWebSearchAction>());
    expect(calls[11].results!.single, isA<UnknownWebSearchResult>());
  }
}

void _expectConversationCalls(
  List<ConversationItem> items,
  List<Map<String, dynamic>> expected,
) {
  expect(items, everyElement(isA<ConversationWebSearchCallItem>()));
  expect(items.map((item) => item.toJson()).toList(), expected);
  final first = items.first as ConversationWebSearchCallItem;
  expect(first.action, isA<WebSearchActionSearch>());
  expect(first.results!.first, isA<WebSearchImageResult>());
  expect(
    first.agent?.agentName,
    expected.first.containsKey('agent') ? 'web_worker' : null,
  );
}

Map<String, (Map<String, dynamic>, String)> _malformedCalls() {
  const base = <String, dynamic>{
    'type': 'web_search_call',
    'id': 'ws_bad',
    'status': 'completed',
  };
  return {
    'missing id': ({'type': 'web_search_call', 'status': 'completed'}, '.id'),
    'wrong status': ({...base, 'status': 1}, '.status'),
    'null action': ({...base, 'action': null}, '.action'),
    'wrong action object': ({...base, 'action': <Object>[]}, '.action'),
    'missing action type': (
      {...base, 'action': <String, dynamic>{}},
      '.action.type',
    ),
    'null queries': (
      {
        ...base,
        'action': {'type': 'search', 'queries': null},
      },
      '.action.queries',
    ),
    'wrong query element': (
      {
        ...base,
        'action': {
          'type': 'search',
          'queries': [1],
        },
      },
      '.action.queries[0]',
    ),
    'null deprecated query': (
      {
        ...base,
        'action': {'type': 'search', 'query': null},
      },
      '.action.query',
    ),
    'wrong sources': (
      {
        ...base,
        'action': {'type': 'search', 'sources': 'bad'},
      },
      '.action.sources',
    ),
    'missing source url': (
      {
        ...base,
        'action': {
          'type': 'search',
          'sources': [
            {'type': 'url'},
          ],
        },
      },
      '.action.sources[0].url',
    ),
    'wrong source type': (
      {
        ...base,
        'action': {
          'type': 'search',
          'sources': [
            {'type': 'future', 'url': 'https://source.example'},
          ],
        },
      },
      '.action.sources[0].type',
    ),
    'wrong open URL': (
      {
        ...base,
        'action': {'type': 'open_page', 'url': 1},
      },
      '.action.url',
    ),
    'missing find URL': (
      {
        ...base,
        'action': {'type': 'find_in_page', 'pattern': 'query'},
      },
      '.action.url',
    ),
    'missing find pattern': (
      {
        ...base,
        'action': {'type': 'find_in_page', 'url': 'https://source.example'},
      },
      '.action.pattern',
    ),
    'null results': ({...base, 'results': null}, '.results'),
    'wrong result object': (
      {
        ...base,
        'results': ['bad'],
      },
      '.results[0]',
    ),
    'missing result type': (
      {
        ...base,
        'results': [<String, dynamic>{}],
      },
      '.results[0].type',
    ),
    'missing image URL': (
      {
        ...base,
        'results': [
          {
            'type': 'image_result',
            'source_website_url': 'https://source.example',
          },
        ],
      },
      '.results[0].image_url',
    ),
    'null image source URL': (
      {
        ...base,
        'results': [
          {
            'type': 'image_result',
            'image_url': 'https://image.example',
            'source_website_url': null,
          },
        ],
      },
      '.results[0].source_website_url',
    ),
    'wrong image caption': (
      {
        ...base,
        'results': [
          {
            'type': 'image_result',
            'image_url': 'https://image.example',
            'source_website_url': 'https://source.example',
            'caption': 1,
          },
        ],
      },
      '.results[0].caption',
    ),
    'wrong beta agent': ({...base, 'agent': <Object>[]}, '.agent'),
    'missing beta agent name': (
      {...base, 'agent': <String, dynamic>{}},
      '.agent.agent_name',
    ),
  };
}

Map<String, (Map<String, dynamic>, String)> _malformedTools() {
  const base = <String, dynamic>{'type': 'web_search'};
  return {
    'null external access': (
      {...base, 'external_web_access': null},
      'external_web_access',
    ),
    'wrong filters': ({...base, 'filters': <Object>[]}, 'filters'),
    'wrong allowed domain': (
      {
        ...base,
        'filters': {
          'allowed_domains': [1],
        },
      },
      'allowed_domains',
    ),
    'wrong blocked domain': (
      {
        ...base,
        'filters': {
          'blocked_domains': [1],
        },
      },
      'blocked_domains',
    ),
    'wrong location': ({...base, 'user_location': <Object>[]}, 'user_location'),
    'wrong city': (
      {
        ...base,
        'user_location': {'city': 1},
      },
      'city',
    ),
    'null budget': (
      {...base, 'return_token_budget': null},
      'return_token_budget',
    ),
    'unknown budget': (
      {...base, 'return_token_budget': 'future'},
      'return_token_budget',
    ),
    'null image settings': (
      {...base, 'image_settings': null},
      'image_settings',
    ),
    'nonpositive image maximum': (
      {
        ...base,
        'image_settings': {'max_results': 0},
      },
      'max_results',
    ),
    'fractional image maximum': (
      {
        ...base,
        'image_settings': {'max_results': 1.5},
      },
      'max_results',
    ),
    'null image caption': (
      {
        ...base,
        'image_settings': {'caption': null},
      },
      'caption',
    ),
    'wrong image caption': (
      {
        ...base,
        'image_settings': {'caption': 'true'},
      },
      'caption',
    ),
    for (final field in [
      'external_web_access',
      'filters',
      'return_token_budget',
      'image_settings',
    ])
      'preview GA-only $field': (
        {
          'type': 'web_search_preview',
          field: switch (field) {
            'external_web_access' => false,
            'return_token_budget' => 'default',
            _ => <String, dynamic>{},
          },
        },
        field,
      ),
  };
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
  'id': 'resp_web',
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

Map<String, dynamic> _listJson(List<Map<String, dynamic>> data) => {
  'object': 'list',
  'data': data,
  'has_more': false,
  'first_id': data.first['id'],
  'last_id': data.last['id'],
};

List<Map<String, dynamic>> _events(Map<String, dynamic> response) {
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
