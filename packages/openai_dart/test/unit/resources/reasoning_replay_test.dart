import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  for (final beta in [false, true]) {
    test(
      'typed reasoning survives tool-turn replay and retrieval beta=$beta',
      () async {
        final reasoning = _reasoning(beta: beta);
        final function = _function(beta: beta);
        final initial = _history();
        var requests = 0;
        final client = _client(
          MockClient((request) async {
            requests++;
            expect(request.headers['authorization'], 'Bearer local-fixture');
            expect(
              request.headers['OpenAI-Beta'],
              beta ? 'responses_multi_agent=v1' : null,
            );
            expect(
              request.url.queryParameters,
              beta ? {'beta': 'true'} : isEmpty,
            );
            if (requests == 1) {
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              expect(jsonDecode(request.body), _request(initial).toJson());
              return _json(_response([reasoning, function], id: 'resp_tool'));
            }
            if (requests == 2) {
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              final body = jsonDecode(request.body) as Map<String, dynamic>;
              expect(body['store'], isFalse);
              expect(body.containsKey('previous_response_id'), isFalse);
              expect(body['input'], [
                ...initial.map((item) => item.toJson()),
                reasoning,
                function,
                _toolResult().toJson(),
              ]);
              return _json(_response([], id: 'resp_final'));
            }
            expect(requests, 3);
            expect(request.method, 'GET');
            expect(request.url.path, '/v1/responses/resp_tool/input_items');
            return _json({
              'object': 'list',
              'data': [reasoning],
              'has_more': false,
              'first_id': 'rs_fixture',
              'last_id': 'rs_fixture',
            });
          }),
        );

        final first = await client.responses.create(
          _request(initial),
          beta: beta,
        );
        final output = first.output.first as ReasoningItem;
        final replay = output.toInput();
        expect(replay, isA<ReasoningInputItem>());
        expect(replay.toJson(), reasoning);
        expect(replay.status, ItemStatus.completed);
        expect(replay.agent?.agentName, beta ? 'worker' : null);
        final second = await client.responses.create(
          _request([
            ...initial,
            replay,
            Item.fromJson(first.functionCalls.single.toJson()),
            _toolResult(),
          ]),
          beta: beta,
        );
        expect(second.id, 'resp_final');

        final page = await client.responses.inputItems.list(
          first.id,
          beta: beta,
        );
        expect(page.data.single, isA<ReasoningInputItem>());
        expect(page.data.single.toJson(), reasoning);
        expect(page.data.single, replay);
        expect(requests, 3);
      },
    );
  }

  test(
    'issue 429 reasoning text remains a reasoning item for a DeepSeek endpoint',
    () async {
      final wire = <String, dynamic>{
        'type': 'reasoning',
        'id': 'rs_example',
        'summary': <dynamic>[],
        'content': [
          {
            'type': 'reasoning_text',
            'text': 'Synthetic provider reasoning fixture.',
          },
        ],
      };
      final parsed = Item.fromJson(wire);
      expect(parsed, isA<ReasoningInputItem>());
      expect(parsed.toJson(), wire);
      final converted = (OutputItem.fromJson(wire) as ReasoningItem).toInput();
      expect(converted, parsed);
      var requests = 0;
      final client = _client(
        MockClient((request) async {
          requests++;
          expect(request.method, 'POST');
          expect(
            request.url.toString(),
            'https://api.deepseek.com/v1/responses',
          );
          expect(request.headers['authorization'], 'Bearer local-fixture');
          expect(jsonDecode(request.body), {
            'model': 'fixture-model',
            'input': [wire, MessageItem.userText('Continue.').toJson()],
            'store': false,
          });
          return _json(_response([], id: 'resp_provider_fixture'));
        }),
        baseUrl: 'https://api.deepseek.com/v1',
      );
      final response = await client.responses.create(
        CreateResponseRequest(
          model: 'fixture-model',
          input: ResponseInput.items([
            converted,
            MessageItem.userText('Continue.'),
          ]),
          store: false,
        ),
      );
      expect(response.id, 'resp_provider_fixture');
      expect(requests, 1);
    },
  );

  test(
    'explicit nullable encrypted content survives public typed replay',
    () async {
      final wire = _reasoning()..['encrypted_content'] = null;
      final replay = (OutputItem.fromJson(wire) as ReasoningItem).toInput();
      expect(replay.toJson(), wire);
      var requests = 0;
      final client = _client(
        MockClient((request) async {
          requests++;
          expect(request.method, 'POST');
          expect(request.url.path, '/v1/responses');
          final input = (jsonDecode(request.body) as Map)['input'] as List;
          expect(input.single, wire);
          expect(
            (input.single as Map).containsKey('encrypted_content'),
            isTrue,
          );
          return _json(_response([]));
        }),
      );
      final result = await client.responses.create(_request([replay]));
      expect(result.id, 'resp_fixture');
      expect(requests, 1);
    },
  );

  test(
    'finalized SSE reasoning converts to typed replay without losing opaque data',
    () async {
      final wire = _reasoning();
      final initial = _history();
      var requests = 0;
      final client = _client(
        MockClient((request) async {
          requests++;
          expect(request.method, 'POST');
          expect(request.url.path, '/v1/responses');
          expect(request.headers['authorization'], 'Bearer local-fixture');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          if (requests == 1) {
            expect(body['stream'], isTrue);
            expect(
              body['input'],
              initial.map((item) => item.toJson()).toList(),
            );
            final events = [
              {
                'type': 'response.output_item.done',
                'output_index': 0,
                'sequence_number': 1,
                'item': wire,
              },
              {
                'type': 'response.completed',
                'sequence_number': 2,
                'response': _response([wire, _function()]),
              },
            ];
            return http.Response(
              '${events.map((event) => 'data: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }
          expect(requests, 2);
          expect(body.containsKey('stream'), isFalse);
          expect(body['input'], [
            ...initial.map((item) => item.toJson()),
            wire,
            _function(),
            _toolResult().toJson(),
          ]);
          return _json(_response([], id: 'resp_sse_continued'));
        }),
      );
      final events = await client.responses
          .createStream(_request(initial))
          .toList();
      expect(events, hasLength(2));
      final done = events.first as OutputItemDoneEvent;
      final reasoning = done.item as ReasoningItem;
      final terminal = (events.last as ResponseCompletedEvent).response;
      expect(terminal.output.first, reasoning);
      expect(reasoning.toInput().toJson(), wire);
      final next = await client.responses.create(
        _request([
          ...initial,
          reasoning.toInput(),
          Item.fromJson(terminal.functionCalls.single.toJson()),
          _toolResult(),
        ]),
      );
      expect(next.id, 'resp_sse_continued');
      expect(requests, 2);
    },
  );

  test(
    'finalized WebSocket reasoning is replayed as typed input in wire order',
    () async {
      final socket = _Socket();
      final client = OpenAIClient();
      final connection = await client.responses.connect(
        connector: (uri, {headers}) async => socket,
      );
      addTearDown(() async {
        await connection.close();
        client.close();
      });
      final initial = _history();
      connection.create(_request(initial), streamId: 'main');
      final pending = connection.events.take(2).toList();
      final wire = _reasoning();
      socket
        ..frame({
          'type': 'response.output_item.done',
          'stream_id': 'main',
          'output_index': 0,
          'sequence_number': 1,
          'item': wire,
        })
        ..frame({
          'type': 'response.completed',
          'stream_id': 'main',
          'sequence_number': 2,
          'response': _response([wire, _function()]),
        });
      final events = await pending;
      expect(events.map((event) => event.streamId), ['main', 'main']);
      final done =
          (events.first as ResponsesStreamEvent).event as OutputItemDoneEvent;
      final reasoning = (done.item as ReasoningItem).toInput();
      final terminal =
          ((events.last as ResponsesStreamEvent).event
                  as ResponseCompletedEvent)
              .response;
      final nextRequest = _request([
        ...initial,
        reasoning,
        Item.fromJson(terminal.functionCalls.single.toJson()),
        _toolResult(),
      ]);
      connection.create(nextRequest, streamId: 'main');
      expect(socket.sent, hasLength(2));
      expect(socket.sent.last, {
        ...nextRequest.toJson(),
        'type': 'response.create',
        'stream_id': 'main',
      });
      expect(socket.sent.last['input'], [
        ...initial.map((item) => item.toJson()),
        wire,
        _function(),
        _toolResult().toJson(),
      ]);
      expect(socket.sent.last.containsKey('stream'), isFalse);
      expect(
        (socket.sent.last['input'] as List)[initial.length],
        isNot(containsPair('role', 'assistant')),
      );
      expect(reasoning.encryptedContent, 'opaque-synthetic-reasoning');
    },
  );
}

List<Item> _history() => [
  MessageItem.userText('Earlier question.'),
  MessageItem.assistantText('Earlier answer.'),
  MessageItem.userText('Check the local status.'),
];

CreateResponseRequest _request(List<Item> input) => CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.items(input),
  store: false,
  tools: [
    ResponseTool.function(
      name: 'status',
      parameters: const {'type': 'object', 'properties': <String, dynamic>{}},
    ),
  ],
);

FunctionCallOutputItem _toolResult() =>
    FunctionCallOutputItem.string(callId: 'call_fixture', output: 'healthy');

Map<String, dynamic> _reasoning({bool beta = false}) => {
  'type': 'reasoning',
  'id': 'rs_fixture',
  'summary': [
    {'type': 'summary_text', 'text': 'Synthetic reasoning summary.'},
  ],
  'content': [
    {'type': 'reasoning_text', 'text': 'Synthetic provider reasoning fixture.'},
  ],
  'encrypted_content': 'opaque-synthetic-reasoning',
  'status': 'completed',
  if (beta) 'agent': {'agent_name': 'worker'},
};

Map<String, dynamic> _function({bool beta = false}) => {
  'type': 'function_call',
  'id': 'fc_fixture',
  'call_id': 'call_fixture',
  'name': 'status',
  'arguments': '{}',
  'status': 'completed',
  if (beta) 'agent': {'agent_name': 'worker'},
};

Map<String, dynamic> _response(
  List<Map<String, dynamic>> output, {
  String id = 'resp_fixture',
}) => {
  'id': id,
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'model': 'fixture-model',
  'output': output,
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <dynamic>[],
  'parallel_tool_calls': false,
  'metadata': <String, dynamic>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};

OpenAIClient _client(
  http.Client mock, {
  String baseUrl = 'https://api.openai.com/v1',
}) {
  final client = OpenAIClient(
    config: OpenAIConfig(
      baseUrl: baseUrl,
      authProvider: const ApiKeyProvider('local-fixture'),
      retryPolicy: const RetryPolicy(maxRetries: 0),
    ),
    httpClient: mock,
  );
  addTearDown(client.close);
  addTearDown(mock.close);
  return client;
}

http.Response _json(Map<String, dynamic> json) => http.Response(
  jsonEncode(json),
  200,
  headers: {'content-type': 'application/json'},
);

class _Socket implements ws.WebSocket {
  final _controller = StreamController<ws.WebSocketEvent>();
  final sent = <Map<String, dynamic>>[];
  void frame(Map<String, dynamic> json) =>
      _controller.add(ws.TextDataReceived(jsonEncode(json)));
  @override
  Stream<ws.WebSocketEvent> get events => _controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) =>
      sent.add(jsonDecode(text) as Map<String, dynamic>);
  @override
  void sendBytes(Uint8List bytes) =>
      throw UnsupportedError('Text fixture only.');
  @override
  Future<void> close([int? code, String? reason]) async {
    if (_controller.isClosed) return;
    _controller.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
    unawaited(_controller.close());
  }
}
