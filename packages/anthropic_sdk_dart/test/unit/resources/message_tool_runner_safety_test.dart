import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _definition = Tool(
  name: 'calculate',
  inputSchema: InputSchema(
    properties: {
      'value': {'type': 'integer'},
    },
  ),
);

void _lifecycleTests() {
  late MockHttpClient transport;
  late AnthropicClient client;
  late MessageCreateRequest request;

  setUp(() {
    transport = MockHttpClient()
      ..queueJsonResponse({
        ...MockResponses.message(id: 'msg_tool', stopReason: 'tool_use'),
        'content': [
          {
            'type': 'tool_use',
            'id': 'toolu_fixture',
            'name': 'calculate',
            'input': {'value': 1},
          },
        ],
      })
      ..queueJsonResponse(MockResponses.message(text: 'finished'));
    client = AnthropicClient.withApiKey('fixture', httpClient: transport);
    addTearDown(client.close);
    request = MessageCreateRequest(
      model: 'claude-sonnet-5',
      maxTokens: 128,
      messages: [InputMessage.user('Run a tool.')],
    );
  });

  test(
    'a callback-local SDK request abort is an ordinary tool failure',
    () async {
      final toolAbort = AbortedException(
        message: 'Local subrequest canceled',
        correlationId: 'child_request',
        timestamp: DateTime.utc(2026, 11, 11),
        stage: AbortionStage.beforeRequest,
      );
      final errors = <Object>[];
      final result = await client.messages.runTools(
        request,
        tools: [
          RunnableMessageTool<int>(
            definition: _definition,
            decode: (input) => input['value'] as int,
            run: (_, _) => throw toolAbort,
          ),
        ],
        onToolError: (_, error, _) => errors.add(error),
      );
      expect(errors, [toolAbort]);
      expect(result.message.text, 'finished');
      expect(transport.requests, hasLength(2));
      expect(_lastToolResult(transport), containsPair('is_error', true));
    },
  );

  test(
    'closing the client from onTurn prevents new local tool side effects',
    () async {
      var calls = 0;
      await expectLater(
        client.messages.runTools(
          request,
          tools: [
            RunnableMessageTool<int>(
              definition: _definition,
              decode: (input) => input['value'] as int,
              run: (_, _) {
                calls++;
                return MessageToolResult.text('side effect');
              },
            ),
          ],
          onTurn: (_) => client.close(),
        ),
        throwsStateError,
      );
      expect(transport.requests, hasLength(1));
      expect(calls, 0);
    },
  );

  test(
    'aborting from input decode prevents the subsequent handler side effect',
    () async {
      final abort = Completer<void>();
      var calls = 0;
      await expectLater(
        client.messages.runTools(
          request,
          tools: [
            RunnableMessageTool<int>(
              definition: _definition,
              decode: (input) {
                abort.complete();
                return input['value'] as int;
              },
              run: (_, _) {
                calls++;
                return MessageToolResult.text('side effect');
              },
            ),
          ],
          abortTrigger: abort.future,
        ),
        throwsA(isA<AbortedException>()),
      );
      expect(transport.requests, hasLength(1));
      expect(calls, 0);
    },
  );
}

const _tool = Tool(name: 'calculate', inputSchema: InputSchema());
const Map<String, Object> _call = {
  'type': 'tool_use',
  'id': 'toolu_fixture',
  'name': 'calculate',
  'input': <String, dynamic>{},
};

void _admissionTests() {
  late MockHttpClient transport;
  late AnthropicClient client;
  late MessageCreateRequest request;
  late int calls;
  late RunnableMessageTool<int> tool;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient.withApiKey('fixture', httpClient: transport);
    addTearDown(client.close);
    request = MessageCreateRequest(
      model: 'claude-sonnet-5',
      maxTokens: 128,
      messages: [InputMessage.user('Run a tool.')],
    );
    calls = 0;
    tool = RunnableMessageTool<int>(
      definition: _tool,
      decode: (_) => 1,
      run: (_, _) {
        calls++;
        return MessageToolResult.text('side effect');
      },
    );
  });

  test('a non-assistant role must not dispatch a local callback', () async {
    transport
      ..queueJsonResponse({
        ...MockResponses.message(stopReason: 'tool_use'),
        'role': 'user',
        'content': [_call],
      })
      ..queueJsonResponse(MockResponses.message(text: 'finished'));
    try {
      await client.messages.runTools(request, tools: [tool]);
    } on FormatException {
      // Rejection or a raw unfinished reply is safe here.
    }
    expect(calls, 0);
    expect(transport.requests, hasLength(1));
  });

  for (final id in ['', 'invalid id']) {
    test('an invalid provider call ID "$id" must not dispatch', () async {
      transport
        ..queueJsonResponse({
          ...MockResponses.message(stopReason: 'tool_use'),
          'content': [
            {..._call, 'id': id},
          ],
        })
        ..queueJsonResponse(MockResponses.message(text: 'finished'));
      try {
        await client.messages.runTools(request, tools: [tool]);
      } on FormatException {
        // Rejection or a raw unfinished reply is safe here.
      }
      expect(calls, 0);
      expect(transport.requests, hasLength(1));
    });
  }

  test('compaction tool changes from this reply gate its callback', () async {
    transport
      ..queueJsonResponse({
        ...MockResponses.message(stopReason: 'tool_use'),
        'content': [
          {
            'type': 'compaction',
            'content': 'summary',
            'signature': 'signed',
            'tool_changes': [
              {
                'type': 'tool_removal',
                'tool': {'type': 'tool_reference', 'name': 'calculate'},
              },
            ],
          },
          _call,
        ],
      })
      ..queueJsonResponse(MockResponses.message(text: 'finished'));
    final result = await client.messages.runTools(
      request,
      tools: [tool],
      betas: ['inline-tools-2026-09-15', 'compact-2026-01-12'],
    );
    expect(calls, 0);
    expect(result.message.text, 'finished');
    expect(_lastToolResult(transport), containsPair('is_error', true));
  });
}

void _snapshotTests() {
  test(
    'a matched caller definition cannot mutate away from its registered decoder',
    () async {
      final mutable = <String, dynamic>{'type': 'integer'};
      final definition = Tool(
        name: 'calculate',
        inputSchema: InputSchema(properties: {'value': mutable}),
      );
      final transport = MockHttpClient()
        ..queueJsonResponse({
          ...MockResponses.message(id: 'msg_tool', stopReason: 'tool_use'),
          'content': [
            {
              'type': 'tool_use',
              'id': 'toolu_fixture',
              'name': 'calculate',
              'input': {'value': 1},
            },
          ],
        })
        ..queueJsonResponse(MockResponses.message(text: 'finished'));
      final client = AnthropicClient.withApiKey(
        'fixture',
        httpClient: transport,
      );
      addTearDown(client.close);
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 128,
        tools: [ToolDefinition.custom(definition)],
        messages: [InputMessage.user('Run a tool.')],
      );
      await client.messages.runTools(
        request,
        tools: [
          RunnableMessageTool<int>(
            definition: definition,
            decode: (input) => input['value'] as int,
            run: (_, _) => MessageToolResult.text('tool ran'),
          ),
        ],
        onTurn: (_) => mutable['type'] = 'string',
      );
      final toolSchemas = transport.requests.map((request) {
        final body =
            jsonDecode((request as http.Request).body) as Map<String, dynamic>;
        final tool =
            (body['tools'] as List<dynamic>).single as Map<String, dynamic>;
        final schema = tool['input_schema'] as Map<String, dynamic>;
        final properties = schema['properties'] as Map<String, dynamic>;
        final value = properties['value'] as Map<String, dynamic>;
        return value['type'];
      });
      expect(toolSchemas, ['integer', 'integer']);
    },
  );
}

void main() {
  group('callback lifecycle', _lifecycleTests);
  group('tool-call admission', _admissionTests);
  group('callback schema', _snapshotTests);
}

Map<String, dynamic> _lastToolResult(MockHttpClient transport) {
  final body =
      jsonDecode((transport.requests.last as http.Request).body)
          as Map<String, dynamic>;
  final last = (body['messages'] as List<dynamic>).last as Map<String, dynamic>;
  return (last['content'] as List<dynamic>).single as Map<String, dynamic>;
}
