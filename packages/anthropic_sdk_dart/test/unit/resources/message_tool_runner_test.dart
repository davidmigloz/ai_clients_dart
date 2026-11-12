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
      'input': {'type': 'integer'},
    },
    required: ['input'],
    extra: {'additionalProperties': false},
  ),
  strict: true,
);

void main() {
  late MockHttpClient httpClient;
  late AnthropicClient client;
  late MessageCreateRequest request;

  setUp(() {
    httpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('tool-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: httpClient,
    );
    request = MessageCreateRequest(
      model: 'claude-sonnet-5',
      maxTokens: 256,
      messages: [InputMessage.user('Double 3.')],
    );
  });

  tearDown(() => client.close());

  test('typed strict callbacks produce ordered results and replay', () async {
    final calls = [_toolUse('one'), _toolUse('two', input: 7)];
    httpClient
      ..queueJsonResponse(_reply('msg_tools', 'tool_use', calls))
      ..queueJsonResponse(MockResponses.message(text: '6 and 14'));
    final observed = <String>[];
    final turns = <String>[];
    final result = await client.messages.runTools(
      request,
      tools: [
        _calculator((value, call) {
          observed.add(call.toolUse.id);
          expect(
            () => call.toolUse.input['input'] = 99,
            throwsUnsupportedError,
          );
          return MessageToolResult.text('${value * 2}');
        }),
      ],
      maxIterations: 2,
      betas: ['fixture-beta'],
      userProfileId: 'uprof_fixture',
      workspaceId: 'wrk_fixture',
      onTurn: (message) => turns.add(message.id),
    );
    expect(observed, ['one', 'two']);
    expect(turns, ['msg_tools', 'msg_test123']);
    expect(result.message.text, '6 and 14');
    expect(result.iterations, 2);
    expect(result.iterationLimitReached, isFalse);
    expect(result.history, hasLength(3));
    expect(request.tools, isNull);
    expect(request.messages, hasLength(1));

    for (final sent in httpClient.requests) {
      expect(sent.url.path, '/v1/messages');
      expect(sent.headers['x-api-key'], 'tool-key');
      expect(sent.headers['anthropic-beta'], 'fixture-beta');
      expect(sent.headers['anthropic-user-profile-id'], 'uprof_fixture');
      expect(sent.headers['anthropic-workspace-id'], 'wrk_fixture');
      expect(_body(sent)['tools'], [_definition.toJson()]);
    }
    expect(_body(httpClient.requests.last)['messages'], [
      request.messages.single.toJson(),
      {'role': 'assistant', 'content': calls},
      {
        'role': 'user',
        'content': [_result('one', '6'), _result('two', '14')],
      },
    ]);
  });

  test(
    'tool definitions already present keep their place in the request',
    () async {
      final definitions = [
        ToolDefinition.builtIn(BuiltInTool.webSearch()),
        ToolDefinition.custom(_definition),
      ];
      httpClient.queueJsonResponse(MockResponses.message());
      await client.messages.runTools(
        request.copyWith(tools: definitions),
        tools: [_calculator((_, _) => MessageToolResult.text('unused'))],
      );
      expect(_body(httpClient.lastRequest!)['tools'], [
        for (final definition in definitions) definition.toJson(),
      ]);
    },
  );

  test(
    'reports decoder and callback failures without sending exception text',
    () async {
      httpClient
        ..queueJsonResponse(
          _reply('msg_tools', 'tool_use', [
            _toolUse('bad_input', input: 'three'),
            _toolUse('throws'),
            _toolUse('missing', name: 'undeclared'),
            _toolUse('failure', input: 10),
          ]),
        )
        ..queueJsonResponse(MockResponses.message());
      final errors = <Object>[];
      await client.messages.runTools(
        request,
        tools: [
          _calculator((value, _) {
            if (value == 10) {
              return MessageToolResult.text(
                'Unavailable today.',
                isError: true,
              );
            }
            throw StateError('private internal error');
          }),
        ],
        onToolError: (_, error, _) => errors.add(error),
      );
      expect(errors, [isA<FormatException>(), isA<StateError>()]);
      expect(_body(httpClient.lastRequest!)['messages'], [
        request.messages.single.toJson(),
        isA<Map<String, dynamic>>(),
        {
          'role': 'user',
          'content': [
            _result('bad_input', 'The tool failed to complete.', isError: true),
            _result('throws', 'The tool failed to complete.', isError: true),
            _result(
              'missing',
              'The requested tool has no available callback.',
              isError: true,
            ),
            _result('failure', 'Unavailable today.', isError: true),
          ],
        },
      ]);
    },
  );

  test('honors removal and re-addition in the request history', () async {
    const removed = ToolRemovalInputBlock(
      tool: ToolChangeToolReference('calculate'),
    );
    const added = ToolAdditionInputBlock(
      tool: ToolChangeToolReference('calculate'),
    );
    var executed = 0;
    final tool = _calculator((_, _) {
      executed++;
      return MessageToolResult.text('6');
    });
    for (final blocks in [
      [removed],
      [removed, added],
    ]) {
      httpClient
        ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
        ..queueJsonResponse(MockResponses.message());
      await client.messages.runTools(
        request.copyWith(
          messages: [
            ...request.messages,
            InputMessage(
              role: MessageRole.system,
              content: MessageContent.blocks(blocks),
            ),
          ],
        ),
        tools: [tool],
        betas: ['inline-tools-2026-09-15'],
      );
    }
    expect(executed, 1);
  });

  test('inline replacement cannot reuse a stale callback', () async {
    final replaced = ToolAdditionInputBlock.fromJson({
      'type': 'tool_addition',
      'tool': {
        'type': 'tool_definition',
        'definition': _definition.copyWith(strict: false).toJson(),
      },
    });
    httpClient
      ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
      ..queueJsonResponse(MockResponses.message());
    await client.messages.runTools(
      request.copyWith(
        messages: [
          ...request.messages,
          InputMessage(
            role: MessageRole.system,
            content: MessageContent.blocks([replaced]),
          ),
        ],
      ),
      tools: [_calculator((_, _) => fail('Stale callback was invoked.'))],
      betas: ['inline-tools-2026-09-15'],
    );
    final body = _body(httpClient.lastRequest!);
    expect(body['messages'], [
      request.messages.single.toJson(),
      isA<Map<String, dynamic>>(),
      isA<Map<String, dynamic>>(),
      {
        'role': 'user',
        'content': [
          _result(
            'one',
            'The requested tool has no available callback.',
            isError: true,
          ),
        ],
      },
    ]);
  });

  test('applies summarized tool changes after threshold compaction', () async {
    final summary = {
      'type': 'compaction',
      'content': 'summary',
      'signature': 'signed',
      'tool_changes': [
        {
          'type': 'tool_removal',
          'tool': {'type': 'tool_reference', 'name': 'calculate'},
        },
      ],
    };
    httpClient
      ..queueJsonResponse(_reply('msg_summary', 'compaction', [summary]))
      ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
      ..queueJsonResponse(MockResponses.message());
    final result = await client.messages.runTools(
      request,
      tools: [_calculator((_, _) => fail('Removed callback was invoked.'))],
      betas: ['compact-2026-01-12', 'inline-tools-2026-09-15'],
    );
    expect(result.iterations, 3);
    expect(result.history[1].toJson(), {
      'role': 'assistant',
      'content': [summary],
    });
  });

  test(
    'redemption is initial-only and a returned container is reused',
    () async {
      for (final useThread in [false, true]) {
        httpClient
          ..reset()
          ..queueJsonResponse({
            ..._reply('msg_tools', 'tool_use', [_toolUse('one')]),
            'container': {
              'id': 'container_fixture',
              'expires_at': '2026-11-11T12:00:00Z',
            },
          })
          ..queueJsonResponse(MockResponses.message());
        final result = await client.messages.runTools(
          request.copyWith(
            fallbackCreditToken: const FallbackCreditTokenParam.token(
              'credit-fixture',
            ),
          ),
          tools: [_calculator((_, _) => MessageToolResult.text('6'))],
          useThread: useThread,
        );
        expect(result.message.stopReason, StopReason.endTurn);
        final first = _body(httpClient.requests.first);
        final last = _body(httpClient.requests.last);
        expect(first['fallback_credit_token'], 'credit-fixture');
        expect(last, isNot(contains('fallback_credit_token')));
        expect(last['container'], 'container_fixture');
        expect(result.thread?.params.fallbackCreditToken, isNull);
        expect(result.thread?.fork().params.fallbackCreditToken, isNull);
      }
    },
  );

  test(
    'budget, refusal, and unsupported toolset calls remain pending',
    () async {
      final tool = _calculator((_, _) => fail('Unexpected callback.'));
      httpClient.queueJsonResponse(
        _reply('msg_capped', 'tool_use', [_toolUse('pending')]),
      );
      final capped = await client.messages.runTools(
        request,
        tools: [tool],
        maxIterations: 1,
      );
      expect(capped.iterationLimitReached, isTrue);
      expect(capped.message.content.single, isA<ToolUseBlock>());
      expect(capped.iterations, 1);

      httpClient.queueJsonResponse(
        _reply('msg_refused', 'refusal', [_toolUse('refused')]),
      );
      final refused = await client.messages.runTools(request, tools: [tool]);
      expect(refused.message.stopReason, StopReason.refusal);
      expect(refused.iterationLimitReached, isFalse);

      httpClient.queueJsonResponse(
        _reply('msg_browser', 'tool_use', [
          _toolUse('custom'),
          {..._toolUse('browser', name: 'navigate'), 'toolset_name': 'browser'},
        ]),
      );
      final toolset = await client.messages.runTools(request, tools: [tool]);
      expect(toolset.message.content, hasLength(2));
      expect(toolset.iterations, 1);
      expect(httpClient.requests, hasLength(3));
    },
  );

  test(
    'pause and threshold compaction replay unchanged and run no callbacks',
    () async {
      final pause = [
        {'type': 'text', 'text': 'Still working.'},
      ];
      final compact = [
        {'type': 'compaction', 'content': 'summary', 'signature': 'signed'},
      ];
      httpClient
        ..queueJsonResponse(_reply('msg_paused', 'pause_turn', pause))
        ..queueJsonResponse(_reply('msg_compacted', 'compaction', compact))
        ..queueJsonResponse(MockResponses.message(text: 'Done'));
      const context = ContextManagementConfig(
        edits: [ThresholdCompactionEdit()],
      );
      final result = await client.messages.runTools(
        request.copyWith(contextManagement: context),
        tools: [_calculator((_, _) => fail('Unexpected callback.'))],
        betas: ['compact-2026-01-12', 'inline-tools-2026-09-15'],
      );
      expect(result.iterations, 3);
      expect(result.message.text, 'Done');
      final last = _body(httpClient.lastRequest!);
      expect(last['context_management'], context.toJson());
      expect(last['messages'], [
        request.messages.single.toJson(),
        {'role': 'assistant', 'content': pause},
        {'role': 'assistant', 'content': compact},
      ]);
    },
  );

  test(
    'thread continuation sends only new tool results and previous ID',
    () async {
      httpClient
        ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
        ..queueJsonResponse(MockResponses.message(id: 'msg_final'));
      final result = await client.messages.runTools(
        request,
        tools: [_calculator((_, _) => MessageToolResult.text('6'))],
        useThread: true,
        workspaceId: 'wrk_fixture',
        betas: ['fixture-beta'],
      );
      expect(result.thread!.previousMessageId, 'msg_final');
      expect(_body(httpClient.requests.first)['thread'], {'type': 'create'});
      expect(
        httpClient.requests.last.headers['anthropic-beta'],
        'fixture-beta,message-threads-2026-08-12',
      );
      expect(
        httpClient.requests.last.headers['anthropic-workspace-id'],
        'wrk_fixture',
      );
      final last = _body(httpClient.lastRequest!);
      expect(last['thread'], {
        'type': 'continue',
        'previous_message_id': 'msg_tools',
      });
      expect(last, isNot(contains('tools')));
      expect(last['messages'], [
        {
          'role': 'user',
          'content': [_result('one', '6')],
        },
      ]);
    },
  );

  test('streamed tool calls run only after message_stop', () async {
    httpClient
      ..queueStreamingResponse(_toolEvents())
      ..queueStreamingResponse(MockResponses.streamingEvents(text: '6'));
    var completed = false;
    final result = await client.messages.runTools(
      request,
      tools: [
        _calculator((value, _) {
          expect(completed, isTrue);
          return MessageToolResult.text('${value * 2}');
        }),
      ],
      onEvent: (event) {
        if (event is MessageStopEvent) completed = true;
      },
    );
    expect(result.message.text, '6');
    expect(_body(httpClient.requests.last)['stream'], isTrue);

    httpClient.queueStreamingResponse(_toolEvents()..removeLast());
    await expectLater(
      client.messages.runTools(
        request,
        tools: [_calculator((_, _) => fail('Incomplete turn ran a callback.'))],
        stream: true,
      ),
      throwsStateError,
    );
    expect(httpClient.requests, hasLength(3));
  });

  test('abort interrupts local callback and prevents later calls', () async {
    httpClient.queueJsonResponse(
      _reply('msg_tools', 'tool_use', [_toolUse('one'), _toolUse('two')]),
    );
    final abort = Completer<void>();
    final started = Completer<void>();
    final running = Completer<MessageToolResult>();
    final run = client.messages.runTools(
      request,
      tools: [
        _calculator((_, call) {
          expect(call.abortTrigger, same(abort.future));
          expect(call.toolUse.id, 'one');
          started.complete();
          return running.future;
        }),
      ],
      abortTrigger: abort.future,
    );
    final error = expectLater(run, throwsA(isA<AbortedException>()));
    await started.future;
    abort.complete();
    await error;
    running.completeError(StateError('late callback failure'));
    expect(httpClient.requests, hasLength(1));
  });

  test(
    'rejects duplicate call IDs and conflicting definitions before side effects',
    () async {
      final tool = _calculator((_, _) => fail('Unexpected callback.'));
      await expectLater(
        client.messages.runTools(
          request.copyWith(
            tools: [ToolDefinition.custom(_definition.copyWith(strict: false))],
          ),
          tools: [tool],
        ),
        throwsArgumentError,
      );
      expect(httpClient.requests, isEmpty);
      httpClient.queueJsonResponse(
        _reply('msg_invalid', 'tool_use', [_toolUse('same'), _toolUse('same')]),
      );
      await expectLater(
        client.messages.runTools(request, tools: [tool]),
        throwsFormatException,
      );
      expect(httpClient.requests, hasLength(1));
    },
  );
}

RunnableMessageTool<int> _calculator(
  FutureOr<MessageToolResult> Function(int, MessageToolCall) run,
) => RunnableMessageTool<int>(
  definition: _definition,
  decode: (input) => switch (input) {
    {'input': final int value} => value,
    _ => throw const FormatException('Expected an integer.'),
  },
  run: run,
);

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

Map<String, dynamic> _toolUse(
  String id, {
  String name = 'calculate',
  Object input = 3,
}) => {
  'type': 'tool_use',
  'id': id,
  'name': name,
  'input': {'input': input},
};

Map<String, dynamic> _reply(
  String id,
  String stop,
  List<Map<String, dynamic>> content,
) => {...MockResponses.message(id: id, stopReason: stop), 'content': content};

Map<String, dynamic> _result(String id, String text, {bool isError = false}) =>
    {
      'type': 'tool_result',
      'tool_use_id': id,
      'content': [
        {'type': 'text', 'text': text},
      ],
      if (isError) 'is_error': true,
    };

List<Map<String, dynamic>> _toolEvents() => [
  MockResponses.streamingEvents().first,
  {
    'type': 'content_block_start',
    'index': 0,
    'content_block': {..._toolUse('one'), 'input': <String, Object>{}},
  },
  {
    'type': 'content_block_delta',
    'index': 0,
    'delta': {'type': 'input_json_delta', 'partial_json': '{"input":3}'},
  },
  {'type': 'content_block_stop', 'index': 0},
  {
    'type': 'message_delta',
    'delta': {'stop_reason': 'tool_use'},
    'usage': {'output_tokens': 15},
  },
  {'type': 'message_stop'},
];
