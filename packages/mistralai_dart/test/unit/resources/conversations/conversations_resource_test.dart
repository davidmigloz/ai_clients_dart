import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const Map<String, Object> _usage = {
  'prompt_tokens': 4,
  'completion_tokens': 2,
  'total_tokens': 6,
  'connector_tokens': 3,
  'connectors': {'web_search': 3},
};

const Map<String, Object> _input = {
  'type': 'message.input',
  'role': 'user',
  'id': 'input',
  'object': 'entry',
  'content': [
    {'type': 'text', 'text': 'Read this'},
    {
      'type': 'image_url',
      'image_url': {'url': 'https://example.test/chart.png'},
    },
  ],
};

const Map<String, Object> _output = {
  'type': 'message.output',
  'role': 'assistant',
  'id': 'output',
  'object': 'entry',
  'content': [
    {'type': 'text', 'text': 'First '},
    {'type': 'text', 'text': 'answer'},
  ],
  'created_at': '2026-11-27T13:04:05.123456Z',
};

const Map<String, Object> _call = {
  'type': 'function.call',
  'tool_call_id': 'call-1',
  'name': 'lookup',
  'arguments': {'location': 'Paris'},
  'confirmation_status': 'pending',
};

const Map<String, Object> _result = {
  'type': 'function.result',
  'tool_call_id': 'call-1',
  'result': 'Found',
};

const Map<String, Object> _tool = {
  'type': 'tool.execution',
  'name': 'web_search',
  'arguments': '{"q":"weather"}',
  'info': {
    'citations': ['doc-1'],
  },
};

const Map<String, Object> _handoff = {
  'type': 'agent.handoff',
  'previous_agent_id': 'agent-1',
  'previous_agent_name': 'Router',
  'next_agent_id': 'agent-2',
  'next_agent_name': 'Support',
};

const List<Map<String, Object>> _guardrails = [
  {
    'provider': 'policy',
    'passed': false,
    'details': {
      'policy_ids': ['p1'],
    },
  },
];

const Map<String, Object> _response = {
  'object': 'conversation.response',
  'conversation_id': 'conversation-1',
  'outputs': [_output, _call, _tool, _handoff],
  'usage': _usage,
  'guardrails': _guardrails,
};

const Map<String, Object> _conversation = {
  'id': 'conversation-1',
  'object': 'conversation',
  'agent_id': 'agent-1',
  'agent_version': 'prod',
  'name': 'Support',
  'created_at': '2026-11-27T13:04:05.123456Z',
  'updated_at': '2026-11-27T13:04:11.123459Z',
};

const List<Map<String, Object>> _eventData = [
  {
    'type': 'conversation.response.started',
    'conversation_id': 'conversation-1',
  },
  {
    'type': 'message.output.delta',
    'id': 'output',
    'content_index': 0,
    'output_index': 0,
    'role': 'assistant',
    'content': 'First ',
  },
  {
    'type': 'message.output.delta',
    'id': 'output',
    'content_index': 1,
    'output_index': 0,
    'role': 'assistant',
    'content': {'type': 'text', 'text': 'answer'},
  },
  {
    'type': 'function.call.delta',
    'id': 'function-1',
    'name': 'lookup',
    'tool_call_id': 'call-1',
    'arguments': '{"location":',
    'confirmation_status': 'pending',
    'output_index': 1,
  },
  {
    'type': 'tool.execution.started',
    'id': 'tool-1',
    'name': 'web_search',
    'arguments': '',
  },
  {
    'type': 'tool.execution.delta',
    'id': 'tool-1',
    'name': 'web_search',
    'arguments': '{"q":"weather"}',
  },
  {
    'type': 'tool.execution.done',
    'id': 'tool-1',
    'name': 'web_search',
    'info': {
      'citations': ['doc-1'],
    },
  },
  {
    'type': 'agent.handoff.started',
    'id': 'handoff-1',
    'previous_agent_id': 'agent-1',
    'previous_agent_name': 'Router',
  },
  {
    'type': 'agent.handoff.done',
    'id': 'handoff-1',
    'next_agent_id': 'agent-2',
    'next_agent_name': 'Support',
  },
  {
    'type': 'future.event',
    'raw': {'value': 42},
  },
  {'type': 'conversation.response.done', 'usage': _usage},
];

http.Response _json(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late MistralClient client;
  late List<http.Request> requests;
  late http.Response Function(http.Request) reply;

  setUp(() {
    requests = [];
    client = MistralClient(
      config: const MistralConfig(authProvider: ApiKeyProvider('fixture')),
      httpClient: MockClient((request) async {
        requests.add(request);
        return reply(request);
      }),
    );
    addTearDown(client.close);
  });

  test('lists a bare array and keeps ISO timestamp precision', () async {
    reply = (_) => _json([_conversation]);
    final result = await client.conversations.list(
      page: 2,
      pageSize: 10,
      metadata: {'group': 'test'},
    );
    expect(requests.single.method, 'GET');
    expect(requests.single.url.path, '/v1/conversations');
    expect(requests.single.url.queryParameters, {
      'page': '2',
      'page_size': '10',
      'metadata': '{"group":"test"}',
    });
    final conversation = result.data.single;
    expect(conversation.agentVersion, 'prod');
    expect(conversation.createdAt, 1795784645);
    expect(
      conversation.createdAtDateTime,
      DateTime.utc(2026, 11, 27, 13, 4, 5, 123, 456),
    );
    expect(
      conversation.copyWith(name: 'New').toJson()['updated_at'],
      _conversation['updated_at'],
    );
    expect(conversation.toJson(), _conversation);
  });

  test('retrieves and deletes an encoded conversation path segment', () async {
    reply = (request) => request.method == 'DELETE'
        ? http.Response('', 204)
        : _json(_conversation);
    final conversation = await client.conversations.retrieve(
      conversationId: 'c/a',
    );
    await client.conversations.delete(conversationId: 'c/a');
    expect(conversation.id, 'conversation-1');
    expect(requests.map((request) => request.method), ['GET', 'DELETE']);
    for (final request in requests) {
      expect(request.url.pathSegments, ['v1', 'conversations', 'c/a']);
    }
  });

  test(
    'retrieves history and messages and keeps old getEntries alias',
    () async {
      reply = (request) => _json(
        request.url.path.endsWith('/messages')
            ? {
                'object': 'conversation.messages',
                'conversation_id': 'c',
                'messages': [_input, _output],
              }
            : {
                'object': 'conversation.history',
                'conversation_id': 'c',
                'entries': [_input, _call, _result, _tool, _handoff, _output],
              },
      );
      final history = await client.conversations.getHistory(
        conversationId: 'c',
      );
      final oldHistory = await client.conversations.getEntries(
        conversationId: 'c',
      );
      final messages = await client.conversations.getMessages(
        conversationId: 'c',
      );

      expect(requests.map((request) => request.url.path), [
        '/v1/conversations/c/history',
        '/v1/conversations/c/history',
        '/v1/conversations/c/messages',
      ]);
      expect(history.conversationId, 'c');
      expect(history, oldHistory);
      expect(history.toJson()['entries'], [
        _input,
        _call,
        _result,
        _tool,
        _handoff,
        _output,
      ]);
      expect(messages.conversationId, 'c');
      final input = messages.messages.first as MessageInputEntry;
      expect(input.content, 'Read this');
      expect(input.messageContent, isA<MessagePartsContent>());
      expect(input.toJson(), _input);
      final output = messages.messages.last as MessageOutputEntry;
      expect(output.content, 'First answer');
      expect(output.createdAt, _output['created_at']);
      expect(output.toJson(), _output);
    },
  );

  test(
    'starts with a string input and typed nested completion settings',
    () async {
      reply = (_) => _json(_response);
      final result = await client.conversations.start(
        request: const StartConversationRequest(
          agentId: 'agent-1',
          agentVersion: 'prod',
          inputText: 'Hello',
          handoffExecution: 'client',
          metadata: {'group': 'test'},
          completionArgs: CompletionArgs(
            stop: StopSequence.single('END'),
            toolChoice: ToolChoice.required,
            maxTokens: 64,
          ),
        ),
      );
      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/conversations');
      expect(request.headers['accept'], 'application/json');
      expect(jsonDecode(request.body), {
        'agent_id': 'agent-1',
        'agent_version': 'prod',
        'inputs': 'Hello',
        'handoff_execution': 'client',
        'metadata': {'group': 'test'},
        'completion_args': {
          'max_tokens': 64,
          'stop': 'END',
          'tool_choice': 'required',
        },
        'stream': false,
      });
      expect(result.text, 'First answer');
      expect(result.guardrailResults, _guardrails);
      expect(result.usage?.connectorTokens, 3);
      expect(result.usage?.connectors, {'web_search': 3});
      expect(result.functionCalls.single.toolCallId, 'call-1');
      expect(result.functionCalls.single.argumentsObject, {
        'location': 'Paris',
      });
      expect(result.toolExecutions.single.name, 'web_search');
      expect((result.outputs.last as AgentHandoffEntry).nextAgentId, 'agent-2');
      expect(result.toJson(), _response);
    },
  );

  test(
    'appends typed entries and restarts from the wire entry identifier',
    () async {
      reply = (_) => _json(_response);
      await client.conversations.append(
        conversationId: 'c',
        request: const AppendConversationRequest(
          inputs: [
            FunctionResultEntry(
              callId: 'call-1',
              result: 'Found',
              isError: false,
            ),
          ],
          toolConfirmations: [ToolCallConfirmation.allow(toolCallId: 'call-1')],
          maxTokens: 32,
        ),
      );
      await client.conversations.restart(
        conversationId: 'c',
        request: const RestartConversationRequest(
          entryId: 'input',
          inputText: 'Try again',
          agentVersion: 2,
          store: false,
        ),
      );

      expect(requests.map((request) => request.method), ['POST', 'POST']);
      expect(requests.map((request) => request.url.path), [
        '/v1/conversations/c',
        '/v1/conversations/c/restart',
      ]);
      expect(jsonDecode(requests.first.body), {
        'inputs': [_result],
        'tool_confirmations': [
          {'tool_call_id': 'call-1', 'confirmation': 'allow'},
        ],
        'completion_args': {'max_tokens': 32},
        'stream': false,
      });
      expect(jsonDecode(requests.last.body), {
        'from_entry_id': 'input',
        'inputs': 'Try again',
        'agent_version': 2,
        'store': false,
        'stream': false,
      });
    },
  );

  test('streams the typed events on all three physical routes', () async {
    reply = (_) => http.Response(
      [
        ': keepalive\n\n',
        for (final event in _eventData) 'data: ${jsonEncode(event)}\n\n',
        'data: [DONE]\n\n',
      ].join(),
      200,
      headers: {'content-type': 'text/event-stream; charset=utf-8'},
    );

    final starts = await client.conversations
        .startStream(
          request: const StartConversationRequest(
            model: 'mistral-large-latest',
            inputText: 'Hello',
          ),
        )
        .toList();
    final appends = await client.conversations
        .appendStream(
          conversationId: 'c',
          request: const AppendConversationRequest(inputText: 'Continue'),
        )
        .toList();
    final restarts = await client.conversations
        .restartStream(
          conversationId: 'c',
          request: const RestartConversationRequest(entryId: 'input'),
        )
        .toList();

    expect(requests.map((request) => request.method), ['POST', 'POST', 'POST']);
    expect(requests.map((request) => request.url.path), [
      '/v1/conversations',
      '/v1/conversations/c',
      '/v1/conversations/c/restart',
    ]);
    for (final request in requests) {
      expect(request.headers['accept'], 'text/event-stream');
      expect(request.headers['content-type'], startsWith('application/json'));
      expect(request.headers['authorization'], 'Bearer fixture');
      expect(request.url.hasFragment, isFalse);
    }
    expect(requests.map((request) => jsonDecode(request.body)), [
      {'model': 'mistral-large-latest', 'inputs': 'Hello', 'stream': true},
      {'inputs': 'Continue', 'stream': true},
      {'from_entry_id': 'input', 'stream': true},
    ]);
    expect(starts, appends);
    expect(starts, restarts);
    expect(starts.map((event) => event.toJson()), _eventData);
    expect(starts.first, isA<ConversationResponseStarted>());
    expect(starts[1], isA<ConversationMessageDelta>());
    expect(starts[2], isA<ConversationMessageDelta>());
    expect(starts[3], isA<ConversationFunctionCallDelta>());
    expect(starts[4], isA<ConversationToolExecutionStarted>());
    expect(starts[5], isA<ConversationToolExecutionDelta>());
    expect(starts[6], isA<ConversationToolExecutionDone>());
    expect(starts[7], isA<ConversationAgentHandoffStarted>());
    expect(starts[8], isA<ConversationAgentHandoffDone>());
    expect(starts[9], isA<UnknownConversationEvent>());
    expect(starts.last, isA<ConversationResponseDone>());
  });

  test(
    'updates typed input and generation settings through legacy copyWith',
    () {
      final request = StartConversationRequest.fromJson(const {
        'model': 'mistral-large-latest',
        'inputs': 'Hello',
        'completion_args': {'max_tokens': 10, 'stop': 'END'},
      });

      final updated = request.copyWith(
        inputs: [const MessageInputEntry(content: 'Retry')],
        maxTokens: 20,
      );
      expect(updated.inputText, isNull);
      expect(updated.maxTokens, 20);
      expect(updated.toJson(), {
        'model': 'mistral-large-latest',
        'inputs': [
          {'type': 'message.input', 'role': 'user', 'content': 'Retry'},
        ],
        'completion_args': {'max_tokens': 20, 'stop': 'END'},
      });
      expect(
        request.copyWith(completionArgs: null).toJson(),
        isNot(contains('completion_args')),
      );
    },
  );

  test('keeps legacy tool views in sync with wire arguments and info', () {
    final entry = ToolExecutionEntry.fromJson(_tool);
    expect(entry.input, {'q': 'weather'});
    expect(entry.output, {
      'citations': ['doc-1'],
    });

    final updated = entry.copyWith(
      input: {'q': 'sun'},
      output: {'citations': <String>[]},
    );
    expect(updated.toJson(), {
      'type': 'tool.execution',
      'name': 'web_search',
      'arguments': '{"q":"sun"}',
      'info': {'citations': <String>[]},
    });
  });

  test('accepts an SSE event name for a typed service error', () async {
    reply = (_) => http.Response(
      'event: conversation.response.error\n'
      'data: {"message":"Content blocked","code":4001}\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
    final events = await client.conversations
        .startStream(
          request: const StartConversationRequest(
            model: 'mistral-large-latest',
            inputText: 'Hello',
          ),
        )
        .toList();

    final error = events.single as ConversationResponseError;
    expect(error.message, 'Content blocked');
    expect(error.code, 4001);
  });
}
