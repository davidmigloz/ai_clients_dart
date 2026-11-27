import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _model = 'mistral-large-latest';

const Map<String, Object> _outputMessage = {
  'type': 'message',
  'role': 'assistant',
  'id': 'message-1',
  'status': 'completed',
  'content': [
    {
      'type': 'output_text',
      'text': 'The forecast is clear.',
      'annotations': <Object>[],
    },
    {'type': 'refusal', 'refusal': 'A separate refused item.'},
  ],
};

const Map<String, Object> _functionCall = {
  'type': 'function_call',
  'call_id': 'call-1',
  'name': 'weather',
  'namespace': 'tools',
  'arguments': '{"city":"Madrid"}',
  'status': 'completed',
};

const Map<String, Object> _response = {
  'object': 'response',
  'id': 'response-1',
  'model': _model,
  'created_at': 1759496862.5,
  'parallel_tool_calls': true,
  'tool_choice': 'auto',
  'tools': <Object>[],
  'status': 'completed',
  'output': [
    {
      'type': 'reasoning',
      'id': 'thinking-1',
      'content': [
        {'type': 'reasoning_text', 'text': 'Compute the forecast.'},
      ],
      'summary': [
        {'type': 'summary_text', 'text': 'Checked the weather.'},
      ],
    },
    _functionCall,
    _outputMessage,
  ],
  'usage': {
    'input_tokens': 5,
    'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 1},
    'output_tokens': 8,
    'output_tokens_details': {'reasoning_tokens': 2},
    'total_tokens': 13,
  },
  'future_field': {
    'items': [1, 2],
  },
};

const _simpleRequest = CreateResponseRequest(
  model: _model,
  input: ResponseInput.text('Hello'),
);

MistralClient _client(http.Client transport) {
  final client = MistralClient(
    config: const MistralConfig(authProvider: ApiKeyProvider('fixture')),
    httpClient: transport,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  test('creates a stateless response with multimodal tool history', () async {
    final client = _client(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/responses');
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['authorization'], 'Bearer fixture');
        expect(jsonDecode(request.body), {
          'background': false,
          'truncation': 'disabled',
          'stream': false,
          'model': _model,
          'input': [
            {
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Explain the forecast.'},
                {
                  'type': 'input_image',
                  'image_url': 'https://example.test/forecast.png',
                  'detail': 'low',
                },
                {'type': 'input_file', 'file_id': 'file-42'},
              ],
            },
            _functionCall,
            {
              'type': 'function_call_output',
              'call_id': 'call-1',
              'output': 'clear',
            },
          ],
          'reasoning': {'effort': 'low'},
          'text': {
            'format': {
              'type': 'json_schema',
              'name': 'forecast',
              'schema': {'type': 'object'},
              'strict': true,
            },
          },
          'tools': [
            {
              'type': 'namespace',
              'name': 'tools',
              'description': 'Weather services',
              'tools': [
                {'type': 'function', 'name': 'weather'},
              ],
            },
          ],
          'tool_choice': {'type': 'function', 'name': 'weather'},
        });
        return http.Response(jsonEncode(_response), 200);
      }),
    );

    final result = await client.responses.create(
      request: CreateResponseRequest(
        model: _model,
        stream: true,
        input: ResponseInput.items([
          const ResponseInputMessage(
            role: 'user',
            content: ResponseMessageContent.parts([
              ResponseInputTextPart(text: 'Explain the forecast.'),
              ResponseInputImagePart(
                imageUrl: 'https://example.test/forecast.png',
                detail: 'low',
              ),
              ResponseInputFilePart(fileId: 'file-42'),
            ]),
          ),
          ResponseFunctionCall.fromJson(_functionCall),
          const ResponseFunctionCallOutput(
            callId: 'call-1',
            output: ResponseFunctionOutput.text('clear'),
          ),
        ]),
        reasoning: const ResponseReasoning(effort: ResponseReasoningEffort.low),
        text: const ResponseTextConfig(
          format: ResponseTextFormatJsonSchema(
            name: 'forecast',
            schema: {'type': 'object'},
            strict: true,
          ),
        ),
        tools: const [
          ResponseNamespaceTool(
            name: 'tools',
            description: 'Weather services',
            tools: [ResponseFunctionTool(name: 'weather')],
          ),
        ],
        toolChoice: const ResponseToolChoiceFunction(name: 'weather'),
      ),
    );
    expect(result.outputText, 'The forecast is clear.');
    expect(result.usage!.inputTokensDetails.cacheWriteTokens, 1);
    expect(
      result.output.whereType<ResponseFunctionCall>().single.callId,
      'call-1',
    );
    expect(result.output.first, isA<ResponseReasoningItem>());
    expect(result.toJson(), _response);
    expect(MistralResponse.fromJson(result.toJson()), result);
    expect(MistralResponse.fromJson(result.toJson()).hashCode, result.hashCode);
  });

  test('counts input tokens without generating a response', () async {
    final client = _client(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v1/responses/input_tokens');
        expect(jsonDecode(request.body), {
          'model': _model,
          'input': 'Hello',
          'truncation': 'disabled',
          'instructions': 'Be brief.',
        });
        return http.Response(
          '{"object":"response.input_tokens","input_tokens":9}',
          200,
        );
      }),
    );

    final count = await client.responses.countInputTokens(
      request: const CountResponseInputTokensRequest(
        model: _model,
        input: ResponseInput.text('Hello'),
        instructions: 'Be brief.',
      ),
    );
    expect(count.inputTokens, 9);
  });

  test('streams all 16 pinned events and preserves unknown events', () async {
    const responseValue = {'response': _response};
    const item = {'output_index': 0, 'item': _outputMessage};
    const deltaPosition = {
      'output_index': 0,
      'content_index': 0,
      'item_id': 'message-1',
    };
    const part = {
      ...deltaPosition,
      'part': {'type': 'output_text', 'text': 'Hi', 'annotations': <Object>[]},
    };
    const argumentsPosition = {'item_id': 'fn-1', 'output_index': 1};
    final events = <String, Map<String, Object>>{
      'response.created': responseValue,
      'response.in_progress': responseValue,
      'response.output_item.added': item,
      'response.content_part.added': part,
      'response.output_text.delta': {
        ...deltaPosition,
        'delta': 'Hel',
        'logprobs': [
          {'token': 'Hel', 'logprob': -0.2},
        ],
      },
      'response.output_text.done': {
        ...deltaPosition,
        'text': 'Hello',
        'logprobs': <Object>[],
      },
      'response.reasoning_text.delta': {...deltaPosition, 'delta': 'Think'},
      'response.reasoning_text.done': {...deltaPosition, 'text': 'Thought'},
      'response.function_call_arguments.delta': {
        ...argumentsPosition,
        'delta': '{}',
      },
      'response.function_call_arguments.done': {
        ...argumentsPosition,
        'arguments': '{}',
      },
      'response.content_part.done': part,
      'response.output_item.done': item,
      'response.completed': responseValue,
      'response.incomplete': responseValue,
      'response.failed': responseValue,
      'error': {'message': 'Temporary error', 'code': 'server_error'},
      'response.future_event': {
        'extension': ['kept'],
      },
    };
    final body = StringBuffer();
    var sequence = 0;
    for (final event in events.entries) {
      // SSE metadata supplies the type when the payload omits it.
      body
        ..writeln('event: ${event.key}')
        ..writeln(
          'data: ${jsonEncode({...event.value, 'sequence_number': sequence++})}\n',
        );
    }
    body.writeln('data: [DONE]\n');

    final client = _client(
      MockClient((request) async {
        expect(request.url.path, '/v1/responses');
        expect(request.headers['accept'], 'text/event-stream');
        expect(jsonDecode(request.body), {
          'background': false,
          'truncation': 'disabled',
          'stream': true,
          'model': _model,
          'input': 'Hello',
        });
        return http.Response(
          body.toString(),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    final result = await client.responses
        .createStream(request: _simpleRequest)
        .toList();
    expect(result.map((event) => event.type), events.keys);
    expect(
      result.map((event) => event.sequenceNumber),
      List.generate(events.length, (i) => i),
    );
    expect(
      result.take(16),
      everyElement(isNot(isA<UnknownResponseStreamEvent>())),
    );
    expect(
      result.whereType<ResponseTextDeltaEvent>().single.logprobs.single.logprob,
      -0.2,
    );
    expect(
      result.whereType<ResponseStreamErrorEvent>().single.message,
      'Temporary error',
    );
    expect(result.last.toJson()['extension'], ['kept']);
  });

  test(
    'recognizes untyped stream errors without treating them as events',
    () async {
      final client = _client(
        MockClient(
          (_) async => http.Response(
            'data: {"error":{"message":"Unavailable"}}\n\n',
            200,
          ),
        ),
      );
      await expectLater(
        client.responses.createStream(request: _simpleRequest),
        emitsError(
          isA<StreamException>().having(
            (exception) => exception.message,
            'message',
            'Unavailable',
          ),
        ),
      );
    },
  );

  test('round-trips a function result image without a detail field', () {
    const wire = {
      'type': 'function_call_output',
      'call_id': 'call-42',
      'output': [
        {'type': 'input_image', 'image_url': 'https://example.test/plot.png'},
      ],
    };
    final result = ResponseItem.fromJson(wire) as ResponseFunctionCallOutput;
    final output = result.output as ResponseFunctionOutputParts;
    expect(output.parts.single, isA<ResponseFunctionImagePart>());
    expect(result.toJson(), wire);
  });

  test('rejects persistence via request extras before transport', () async {
    final client = _client(
      MockClient((_) {
        fail('Unsupported payload reached the transport');
      }),
    );
    await expectLater(
      client.responses.create(
        request: _simpleRequest.copyWith(extra: {'store': true}),
      ),
      throwsArgumentError,
    );
  });

  test(
    'abort cancels one Responses stream without closing the client',
    () async {
      final started = Completer<void>();
      final stopped = Completer<void>();
      final pending = StreamController<List<int>>(
        onListen: started.complete,
        onCancel: stopped.complete,
      );
      addTearDown(pending.close);
      final client = _client(
        MockClient.streaming((request, _) async {
          if (request.headers['accept'] == 'text/event-stream') {
            return http.StreamedResponse(pending.stream, 200);
          }
          return http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode(_response))),
            200,
          );
        }),
      );
      final abort = Completer<void>();
      final done = expectLater(
        client.responses.createStream(
          request: _simpleRequest,
          abortTrigger: abort.future,
        ),
        emitsError(isA<AbortedException>()),
      );
      await started.future;
      abort.complete();
      await done;
      await stopped.future.timeout(const Duration(seconds: 2));
      expect(
        (await client.responses.create(request: _simpleRequest)).id,
        'response-1',
      );
    },
  );
}
