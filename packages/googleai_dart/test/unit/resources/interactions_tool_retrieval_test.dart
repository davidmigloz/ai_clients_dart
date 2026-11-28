import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const Map<String, Object> _lookupSchema = {
  'type': 'object',
  'properties': {
    'sku': {'type': 'string'},
  },
  'required': ['sku'],
};
const _lookup = FunctionTool(
  name: 'lookup_inventory',
  description: 'Returns stock available for a SKU.',
  parameters: _lookupSchema,
);
const Map<String, Object> _functionJson = {
  'type': 'function',
  'name': 'lookup_inventory',
  'description': 'Returns stock available for a SKU.',
  'parameters': _lookupSchema,
};
const _requestText = 'How many units of SKU A123 are available?';
const _userStep = UserInputStep(content: [TextContent(text: _requestText)]);
const Map<String, Object> _searchCall = {
  'type': 'tool_search_call',
  'id': 'search_1',
  'arguments': {
    'function_names': ['lookup_inventory'],
  },
  'signature': 'c2VhcmNoKzE=',
};
const Map<String, Object> _searchResult = {
  'type': 'tool_search_result',
  'call_id': 'search_1',
  'result': [_functionJson],
  'signature': 'cmVzdWx0LzE=',
};
const Map<String, Object> _functionCall = {
  'type': 'function_call',
  'id': 'call_1',
  'name': 'lookup_inventory',
  'arguments': {'sku': 'A123'},
  'signature': 'Y2FsbC0x',
};

GoogleAIClient _makeClient(MockClient httpClient) {
  final client = GoogleAIClient(
    config: const GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1,
      interactionsApiVersion: ApiVersion.v1beta,
      authProvider: ApiKeyProvider(
        'fixture-key',
        placement: AuthPlacement.header,
      ),
    ),
    httpClient: httpClient,
  );
  addTearDown(httpClient.close);
  addTearDown(client.close);
  return client;
}

Map<String, dynamic> _readRequest(http.Request request) {
  expect(request.method, 'POST');
  expect(request.url.path, '/v1beta/interactions');
  expect(request.headers['x-goog-api-key'], 'fixture-key');
  return jsonDecode(request.body) as Map<String, dynamic>;
}

http.Response _response(String id, String status, List<Object> steps) =>
    http.Response(
      jsonEncode({'id': id, 'status': status, 'steps': steps}),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  test(
    'server search loads deferred tools and keeps stateless signatures',
    () async {
      const tools = [
        ToolSearchTool(),
        FunctionTool(
          name: 'lookup_inventory',
          description: 'Returns stock available for a SKU.',
          shortDescription: 'Check stock.',
          parameters: _lookupSchema,
          deferLoading: true,
        ),
        McpServerTool(
          name: 'catalog',
          url: 'https://example.test/mcp',
          deferLoading: true,
        ),
      ];
      const wireTools = [
        {'type': 'tool_search'},
        {
          ..._functionJson,
          'defer_loading': true,
          'short_description': 'Check stock.',
        },
        {
          'type': 'mcp_server',
          'name': 'catalog',
          'url': 'https://example.test/mcp',
          'defer_loading': true,
        },
      ];
      const serverSteps = [_searchCall, _searchResult, _functionCall];
      var calls = 0;
      final client = _makeClient(
        MockClient((request) async {
          final body = _readRequest(request);
          expect(body['tools'], wireTools);
          expect(body['store'], isFalse);
          expect(body, isNot(contains('previous_interaction_id')));
          if (++calls == 1) {
            expect(body['input'], [_userStep.toJson()]);
            return _response('int_first', 'requires_action', serverSteps);
          }
          expect(body['input'], [
            _userStep.toJson(),
            ...serverSteps,
            {
              'type': 'function_result',
              'name': 'lookup_inventory',
              'call_id': 'call_1',
              'result': [
                {'type': 'text', 'text': '{"units": 5}'},
              ],
            },
          ]);
          return _response('int_second', 'completed', const [
            {
              'type': 'model_output',
              'content': [
                {'type': 'text', 'text': 'Five are available.'},
              ],
            },
          ]);
        }),
      );

      final first = await client.interactions.create(
        model: 'gemini-4-hydrogen',
        store: false,
        tools: tools,
        input: const InteractionInput.steps([_userStep]),
      );
      final steps = first.steps!;
      final search = steps[0] as ToolSearchCallStep;
      final result = steps[1] as ToolSearchResultStep;
      final call = steps[2] as FunctionCallStep;
      expect(search.arguments?.functionNames, ['lookup_inventory']);
      expect(search.signature, _searchCall['signature']);
      expect(result.callId, search.id);
      expect(result.signature, _searchResult['signature']);
      expect(result.result?.single.toJson(), _functionJson);
      expect(call.signature, _functionCall['signature']);

      final second = await client.interactions.create(
        model: 'gemini-4-hydrogen',
        store: false,
        tools: tools,
        input: InteractionInput.steps([
          _userStep,
          ...steps,
          FunctionResultStep(
            name: call.name,
            callId: call.id,
            result: const ToolResult.contentList([
              FunctionResultSubcontentText(TextContent(text: '{"units": 5}')),
            ]),
          ),
        ]),
      );
      expect(second.outputText, 'Five are available.');
      expect(calls, 2);
    },
  );

  test(
    'client search returns function declarations as a function_result',
    () async {
      const clientSearch = ToolSearchTool(
        execution: ToolSearchExecution.client,
        name: 'search_catalog',
        description: 'Find matching inventory functions.',
        parameters: {
          'type': 'object',
          'properties': {
            'query': {'type': 'string'},
          },
          'required': ['query'],
        },
      );
      const searchTool = {
        'type': 'tool_search',
        'execution': 'client',
        'name': 'search_catalog',
        'description': 'Find matching inventory functions.',
        'parameters': {
          'type': 'object',
          'properties': {
            'query': {'type': 'string'},
          },
          'required': ['query'],
        },
      };
      const reply = {
        'type': 'function_result',
        'name': 'search_catalog',
        'call_id': 'client_call_1',
        'result': [_functionJson],
      };
      var calls = 0;
      final client = _makeClient(
        MockClient((request) async {
          final body = _readRequest(request);
          expect(body['tools'], [searchTool]);
          if (++calls == 1) {
            expect(body['input'], _requestText);
            return _response('int_search', 'requires_action', const [
              {
                'type': 'function_call',
                'id': 'client_call_1',
                'name': 'search_catalog',
                'arguments': {'query': 'inventory'},
              },
            ]);
          }
          expect(body['previous_interaction_id'], 'int_search');
          expect(body['input'], [reply]);
          return _response('int_lookup', 'requires_action', const [
            _functionCall,
          ]);
        }),
      );

      final first = await client.interactions.create(
        model: 'gemini-4-hydrogen',
        tools: const [clientSearch],
        input: const InteractionInput.text(_requestText),
      );
      final call = first.steps!.single as FunctionCallStep;
      expect(call.name, 'search_catalog');
      final second = await client.interactions.create(
        model: 'gemini-4-hydrogen',
        tools: const [clientSearch],
        previousInteractionId: first.id,
        input: InteractionInput.steps([
          FunctionResultStep(
            name: call.name,
            callId: call.id,
            result: const ToolResult.contentList([
              FunctionResultSubcontentFunction(_lookup),
            ]),
          ),
        ]),
      );
      expect(
        (second.steps!.single as FunctionCallStep).name,
        'lookup_inventory',
      );
      final decoded = InteractionStep.fromJson(reply) as FunctionResultStep;
      final result = decoded.result as ToolResultContentList;
      expect(
        (result.items.single as FunctionResultSubcontentFunction).function.name,
        'lookup_inventory',
      );
      expect(decoded.toJson(), reply);
      expect(calls, 2);
    },
  );

  test(
    'public streaming decodes tool search skeletons and partial deltas',
    () async {
      const frames = [
        {
          'event_type': 'step.start',
          'index': 0,
          'step': {'type': 'tool_search_call', 'id': 'search_1'},
        },
        {
          'event_type': 'step.delta',
          'index': 0,
          'delta': {'type': 'tool_search_call'},
        },
        {
          'event_type': 'step.delta',
          'index': 0,
          'delta': {
            'type': 'tool_search_call',
            'arguments': {
              'function_names': ['lookup_inventory'],
            },
            'signature': 'c2VhcmNoKzE=',
          },
        },
        {
          'event_type': 'step.start',
          'index': 1,
          'step': {'type': 'tool_search_result', 'call_id': 'search_1'},
        },
        {
          'event_type': 'step.delta',
          'index': 1,
          'delta': {'type': 'tool_search_result'},
        },
        {
          'event_type': 'step.delta',
          'index': 1,
          'delta': {
            'type': 'tool_search_result',
            'result': [_functionJson],
            'signature': 'cmVzdWx0LzE=',
          },
        },
      ];
      final client = _makeClient(
        MockClient((request) async {
          final body = _readRequest(request);
          expect(request.headers['accept'], 'text/event-stream');
          expect(body['stream'], isTrue);
          expect(body['tools'], [
            {'type': 'tool_search', 'execution': 'server'},
            {..._functionJson, 'defer_loading': true},
          ]);
          return http.Response(
            frames.map((frame) => 'data: ${jsonEncode(frame)}\n\n').join(),
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }),
      );

      final events = await client.interactions
          .createStream(
            model: 'gemini-4-hydrogen',
            input: const InteractionInput.text(_requestText),
            tools: const [
              ToolSearchTool(execution: ToolSearchExecution.server),
              FunctionTool(
                name: 'lookup_inventory',
                description: 'Returns stock available for a SKU.',
                parameters: _lookupSchema,
                deferLoading: true,
              ),
            ],
          )
          .toList();
      expect((events[0] as StepStartEvent).step, isA<ToolSearchCallStep>());
      expect(
        ((events[1] as StepDeltaEvent).delta as ToolSearchCallDelta).arguments,
        isNull,
      );
      expect(
        ((events[2] as StepDeltaEvent).delta as ToolSearchCallDelta)
            .arguments
            ?.functionNames,
        ['lookup_inventory'],
      );
      expect((events[3] as StepStartEvent).step, isA<ToolSearchResultStep>());
      expect(
        ((events[4] as StepDeltaEvent).delta as ToolSearchResultDelta).result,
        isNull,
      );
      expect(
        ((events[5] as StepDeltaEvent).delta as ToolSearchResultDelta)
            .result
            ?.single
            .name,
        'lookup_inventory',
      );
      expect(events.map((event) => event.toJson()), frames);
    },
  );

  test(
    'client-side search accepts function call argument fragments in SSE',
    () async {
      const frames = [
        {
          'event_type': 'step.start',
          'index': 0,
          'step': {
            'type': 'function_call',
            'id': 'search_1',
            'name': 'search_catalog',
            'arguments': '{"query":',
          },
        },
        {
          'event_type': 'step.delta',
          'index': 0,
          'delta': {'type': 'arguments_delta', 'arguments': '"inventory"}'},
        },
        {
          'event_type': 'step.start',
          'index': 1,
          'step': {
            'type': 'function_call',
            'id': 'search_2',
            'name': 'search_catalog',
          },
        },
      ];
      final client = _makeClient(
        MockClient((request) async {
          final body = _readRequest(request);
          expect(body['tools'], [
            {
              'type': 'tool_search',
              'execution': 'client',
              'name': 'search_catalog',
              'description': 'Find a matching function.',
            },
          ]);
          return http.Response(
            frames.map((frame) => 'data: ${jsonEncode(frame)}\n\n').join(),
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }),
      );
      final events = await client.interactions
          .createStream(
            model: 'gemini-4-hydrogen',
            input: const InteractionInput.text(_requestText),
            tools: const [
              ToolSearchTool(
                execution: ToolSearchExecution.client,
                name: 'search_catalog',
                description: 'Find a matching function.',
              ),
            ],
          )
          .toList();
      final first = (events[0] as StepStartEvent).step as FunctionCallStep;
      final delta = (events[1] as StepDeltaEvent).delta as ArgumentsDelta;
      final second = (events[2] as StepStartEvent).step as FunctionCallStep;
      expect(first.arguments, isEmpty);
      expect(jsonDecode('${first.argumentsFragment}${delta.arguments}'), {
        'query': 'inventory',
      });
      expect(first.copyWith().toJson(), frames.first['step']);
      expect(second.arguments, isEmpty);
      expect(second.argumentsFragment, isNull);
      expect(events.map((event) => event.toJson()), frames);
    },
  );

  test('retains a future tool search mode in a public response', () async {
    const futureTool = {
      'type': 'tool_search',
      'execution': 'hybrid',
      'search_settings': {'limit': 5},
    };
    final client = _makeClient(
      MockClient((request) async {
        _readRequest(request);
        return http.Response(
          jsonEncode({
            'id': 'int_future',
            'status': 'completed',
            'tools': [
              {'type': 'tool_search'},
              futureTool,
            ],
            'steps': [
              {
                'type': 'model_output',
                'content': [
                  {'type': 'text', 'text': 'Tool search finished.'},
                ],
              },
            ],
          }),
          200,
        );
      }),
    );

    final interaction = await client.interactions.create(
      model: 'gemini-4-hydrogen',
      input: const InteractionInput.text(_requestText),
    );
    expect(interaction.outputText, 'Tool search finished.');
    expect(interaction.tools, [
      isA<ToolSearchTool>(),
      isA<UnknownInteractionTool>(),
    ]);
    final unknown = interaction.tools!.last as UnknownInteractionTool;
    expect(unknown.type, 'tool_search');
    expect(unknown.rawJson, futureTool);
    expect((interaction.toJson()['tools'] as List<Object?>).last, futureTool);
  });

  test('validates known discriminators and complete tool search steps', () {
    expect(
      () => InteractionStep.fromJson({
        'type': 'tool_search_call',
        'id': 'search_1',
      }),
      throwsFormatException,
    );
    expect(
      () => ToolSearchCallStep.fromJson(_searchResult),
      throwsFormatException,
    );
    expect(
      () => ToolSearchResultStep.fromJson(_searchCall),
      throwsFormatException,
    );
    expect(
      () => ToolSearchCallDelta.fromJson(_searchResult),
      throwsFormatException,
    );
    expect(
      () => ToolSearchResultDelta.fromJson(_searchCall),
      throwsFormatException,
    );
    expect(
      () => ToolSearchTool.fromJson({
        'type': 'tool_search',
        'execution': 'future',
      }),
      throwsFormatException,
    );
    expect(
      () =>
          const ToolSearchTool(execution: ToolSearchExecution.client).toJson(),
      throwsArgumentError,
    );
    expect(
      () => const ToolSearchTool(name: 'not_client').toJson(),
      throwsArgumentError,
    );
    expect(
      InteractionTool.fromJson({
        'type': 'function',
        'defer_loading': false,
      }).toJson(),
      {'type': 'function', 'defer_loading': false},
    );
    expect(
      InteractionTool.fromJson({
        'type': 'mcp_server',
        'defer_loading': false,
      }).toJson(),
      {'type': 'mcp_server', 'defer_loading': false},
    );
  });
}
