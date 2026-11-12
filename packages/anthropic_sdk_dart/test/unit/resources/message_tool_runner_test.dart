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

  test('applies a tool change on the same reply as the tool call', () async {
    httpClient
      ..queueJsonResponse(
        _reply('msg_tools', 'tool_use', [
          {
            'type': 'compaction',
            'content': 'summary',
            'encrypted_content': null,
            'tool_changes': [
              {
                'type': 'tool_removal',
                'tool': {'type': 'tool_reference', 'name': 'calculate'},
              },
            ],
          },
          _toolUse('one'),
        ]),
      )
      ..queueJsonResponse(MockResponses.message());
    await client.messages.runTools(
      request,
      tools: [_calculator((_, _) => fail('Removed callback was invoked.'))],
      betas: ['compact-2026-01-12', 'inline-tools-2026-09-15'],
    );
    expect(_body(httpClient.lastRequest!)['messages'], [
      request.messages.single.toJson(),
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

  test('toolset runners pair results and isolate family failures', () async {
    final order = <String>[];
    final browser = RunnableMessageToolset(
      definition: BuiltInTool.browserToolset(
        configs: const BrowserToolsetConfigs(
          screenshot: ToolsetMemberConfig(enabled: false),
        ),
      ),
      run: (action, call) {
        order.add(call.toolUse.id);
        expect(action, isA<BrowserNavigateAction>());
        return MessageToolResult([
          ToolResultContent.text('Navigated.'),
          ToolResultContent.browserState(
            tabs: const [
              BrowserStateTabEntry(
                tabId: 'tab_fixture',
                title: 'Example',
                url: 'https://example.invalid',
                active: true,
              ),
            ],
          ),
        ]);
      },
    );
    final computer = RunnableMessageToolset(
      definition: BuiltInTool.computerToolset(),
      confirm: (_, _) => true,
      run: (action, call) {
        order.add(call.toolUse.id);
        expect(action, isA<ComputerScreenshotAction>());
        return MessageToolResult.text('Screenshot.');
      },
    );
    final custom = RunnableMessageTool<int>(
      definition: _definition.copyWith(name: 'navigate'),
      decode: (input) => input['input'] as int,
      run: (value, call) {
        order.add(call.toolUse.id);
        return MessageToolResult.text('Custom $value.');
      },
    );
    final calls = [
      _toolsetUse('nav', 'browser', 'navigate', {
        'url': 'https://example.invalid',
      }),
      _toolsetUse('disabled', 'browser', 'screenshot'),
      _toolUse('custom', name: 'navigate'),
      _toolsetUse('skipped', 'browser', 'read_page'),
      _toolsetUse('computer', 'computer', 'screenshot'),
    ];
    httpClient
      ..queueJsonResponse(_reply('msg_tools', 'tool_use', calls))
      ..queueJsonResponse(MockResponses.message(text: 'Done'));

    final result = await client.messages.runTools(
      request,
      tools: [custom],
      toolsets: [browser, computer],
      maxIterations: 2,
    );

    expect(result.message.text, 'Done');
    expect(order, ['nav', 'custom', 'computer']);
    final first = _body(httpClient.requests.first);
    expect(first['tools'], [
      custom.definition.toJson(),
      browser.definition.toJson(),
      computer.definition.toJson(),
    ]);
    final last = _body(httpClient.lastRequest!);
    expect(last['messages'], [
      request.messages.single.toJson(),
      {'role': 'assistant', 'content': calls},
      {
        'role': 'user',
        'content': [
          {
            ..._result('nav', 'Navigated.'),
            'toolset_name': 'browser',
            'content': [
              {'type': 'text', 'text': 'Navigated.'},
              ToolResultContent.browserState(
                tabs: const [
                  BrowserStateTabEntry(
                    tabId: 'tab_fixture',
                    title: 'Example',
                    url: 'https://example.invalid',
                    active: true,
                  ),
                ],
              ).toJson(),
            ],
          },
          {
            ..._result(
              'disabled',
              'The requested toolset action is unavailable.',
              isError: true,
            ),
            'toolset_name': 'browser',
          },
          _result('custom', 'Custom 3.'),
          {
            ..._result(
              'skipped',
              'Not executed: an earlier action in this turn failed.',
              isError: true,
            ),
            'toolset_name': 'browser',
          },
          {..._result('computer', 'Screenshot.'), 'toolset_name': 'computer'},
        ],
      },
    ]);
  });

  test('streamed toolset actions wait for completed frames', () async {
    var completed = false;
    var runs = 0;
    final browser = RunnableMessageToolset(
      definition: BuiltInTool.browserToolset(),
      run: (action, _) {
        expect(completed, isTrue);
        expect(
          action,
          isA<BrowserNavigateAction>().having(
            (value) => value.url,
            'URL',
            'https://example.invalid',
          ),
        );
        runs++;
        return MessageToolResult([
          ToolResultContent.text('Navigated.'),
          ToolResultContent.browserState(
            tabs: const [
              BrowserStateTabEntry(
                tabId: 'tab_fixture',
                title: 'Example',
                url: 'https://example.invalid',
                active: true,
              ),
            ],
          ),
        ]);
      },
    );
    final events = _toolEvents()
      ..[1]['content_block'] = _toolsetUse('navigate', 'browser', 'navigate')
      ..[2]['delta'] = {
        'type': 'input_json_delta',
        'partial_json': '{"url":"https://example.invalid"}',
      };
    httpClient
      ..queueStreamingResponse(events)
      ..queueStreamingResponse(MockResponses.streamingEvents(text: 'Done.'));
    final result = await client.messages.runTools(
      request,
      tools: [],
      toolsets: [browser],
      onEvent: (event) {
        if (event is MessageStopEvent) completed = true;
      },
    );
    expect(result.message.text, 'Done.');
    expect(runs, 1);

    httpClient.queueStreamingResponse(
      events.where((event) => event['type'] != 'content_block_stop').toList(),
    );
    await expectLater(
      client.messages.runTools(
        request,
        tools: [],
        toolsets: [browser],
        stream: true,
      ),
      throwsStateError,
    );
    expect(runs, 1);
    expect(httpClient.requests, hasLength(3));
  });

  test(
    'toolset errors keep family and never send empty error content',
    () async {
      final toolset = RunnableMessageToolset(
        definition: BuiltInTool.browserToolset(),
        run: (_, _) =>
            MessageToolResult([ToolResultContent.text(' ')], isError: true),
      );
      httpClient
        ..queueJsonResponse(
          _reply('msg_tools', 'tool_use', [
            _toolsetUse('empty', 'browser', 'screenshot'),
          ]),
        )
        ..queueJsonResponse(MockResponses.message());
      await client.messages.runTools(request, tools: [], toolsets: [toolset]);
      expect(_body(httpClient.lastRequest!)['messages'], [
        request.messages.single.toJson(),
        isA<Map<String, dynamic>>(),
        {
          'role': 'user',
          'content': [
            {
              ..._result(
                'empty',
                'The tool failed to complete.',
                isError: true,
              ),
              'toolset_name': 'browser',
            },
          ],
        },
      ]);
    },
  );

  test(
    'browser optional member execution requires its explicit enablement',
    () async {
      final toolset = RunnableMessageToolset(
        definition: BuiltInTool.browserToolset(),
        run: (_, _) => fail('A default-disabled action was executed.'),
      );
      httpClient
        ..queueJsonResponse(
          _reply('msg_tools', 'tool_use', [
            _toolsetUse('javascript', 'browser', 'javascript_exec', {
              'text': '1',
            }),
          ]),
        )
        ..queueJsonResponse(MockResponses.message());
      await client.messages.runTools(request, tools: [], toolsets: [toolset]);
      final body = _body(httpClient.lastRequest!);
      expect(body['messages'], [
        request.messages.single.toJson(),
        isA<Map<String, dynamic>>(),
        {
          'role': 'user',
          'content': [
            {
              ..._result(
                'javascript',
                'The requested toolset action is unavailable.',
                isError: true,
              ),
              'toolset_name': 'browser',
            },
          ],
        },
      ]);
    },
  );

  test(
    'abort while confirming cannot start an enabled browser action',
    () async {
      final definition = BuiltInTool.browserToolset(
        configs: const BrowserToolsetConfigs(
          javascriptExec: ToolsetMemberConfig(enabled: true),
        ),
      );
      expect(
        () => RunnableMessageToolset(
          definition: definition,
          run: (_, _) => fail('Unexpected action.'),
        ),
        throwsArgumentError,
      );
      final confirmation = Completer<bool>();
      final confirming = Completer<void>();
      final abort = Completer<void>();
      var calls = 0;
      final toolset = RunnableMessageToolset(
        definition: definition,
        confirm: (action, _) {
          expect(action, isA<BrowserJavascriptExecAction>());
          confirming.complete();
          return confirmation.future;
        },
        run: (_, _) {
          calls++;
          return MessageToolResult.text('executed');
        },
      );
      httpClient.queueJsonResponse(
        _reply('msg_tools', 'tool_use', [
          _toolsetUse('javascript', 'browser', 'javascript_exec', {
            'text': '1',
          }),
        ]),
      );
      final run = client.messages.runTools(
        request,
        tools: [],
        toolsets: [toolset],
        abortTrigger: abort.future,
      );
      final failed = expectLater(run, throwsA(isA<AbortedException>()));
      await confirming.future;
      abort.complete();
      await failed;
      confirmation.complete(true);
      await Future<void>.value();
      expect(calls, 0);
      expect(httpClient.requests, hasLength(1));
    },
  );

  test(
    'default computer key actions require confirmation and halt their own family',
    () async {
      final definition = BuiltInTool.computerToolset();
      expect(
        () => RunnableMessageToolset(
          definition: definition,
          run: (_, _) => fail('Unexpected computer action.'),
        ),
        throwsArgumentError,
      );
      final disabled = BuiltInTool.computerToolset(
        configs: const ComputerToolsetConfigs(
          typeAction: ToolsetMemberConfig(enabled: false),
          key: ToolsetMemberConfig(enabled: false),
          holdKey: ToolsetMemberConfig(enabled: false),
        ),
      );
      expect(
        RunnableMessageToolset(
          definition: disabled,
          run: (_, _) => fail('Unexpected disabled computer action.'),
        ).family,
        'computer',
      );
      final confirmations = <String>[];
      final computer = RunnableMessageToolset(
        definition: definition,
        confirm: (action, _) {
          confirmations.add(action.name);
          return false;
        },
        run: (_, _) => fail('Declined computer action executed.'),
      );
      httpClient
        ..queueJsonResponse(
          _reply('msg_tools', 'tool_use', [
            _toolsetUse('type', 'computer', 'type', {'text': 'fixture'}),
            _toolsetUse('screenshot', 'computer', 'screenshot'),
          ]),
        )
        ..queueJsonResponse(MockResponses.message());
      await client.messages.runTools(request, tools: [], toolsets: [computer]);
      expect(confirmations, ['type']);
      final messages =
          _body(httpClient.lastRequest!)['messages'] as List<Object?>;
      expect(messages.last, {
        'role': 'user',
        'content': [
          {
            ..._result(
              'type',
              'The toolset action was declined.',
              isError: true,
            ),
            'toolset_name': 'computer',
          },
          {
            ..._result(
              'screenshot',
              'Not executed: an earlier computer action in this turn failed.',
              isError: true,
            ),
            'toolset_name': 'computer',
          },
        ],
      });
    },
  );

  test(
    'browser file policy runs before confirmation and file execution',
    () async {
      final definition = BuiltInTool.browserToolset(
        configs: const BrowserToolsetConfigs(
          fileUpload: ToolsetMemberConfig(enabled: true),
        ),
      );
      final seen = <String>[];
      final fileAction = _toolsetUse('upload', 'browser', 'file_upload', {
        'target': {'type': 'ref', 'ref': 'ref_fixture'},
        'paths': ['staged/fixture.txt'],
        'document_ids': ['doc_fixture'],
      });
      for (final approved in [false, true]) {
        final browser = RunnableMessageToolset(
          definition: definition,
          filePolicy: approved
              ? (action, _) {
                  expect(action.target.ref, 'ref_fixture');
                  expect(action.paths, ['staged/fixture.txt']);
                  expect(action.documentIds, ['doc_fixture']);
                  seen.add('policy');
                  return true;
                }
              : null,
          confirm: (_, _) {
            seen.add('confirm');
            return true;
          },
          run: (_, _) {
            seen.add('run');
            return MessageToolResult.text('Uploaded.');
          },
        );
        httpClient
          ..queueJsonResponse(_reply('msg_tools', 'tool_use', [fileAction]))
          ..queueJsonResponse(MockResponses.message());
        await client.messages.runTools(request, tools: [], toolsets: [browser]);
        final messages =
            _body(httpClient.lastRequest!)['messages'] as List<Object?>;
        expect(messages.last, {
          'role': 'user',
          'content': [
            {
              ..._result(
                'upload',
                approved
                    ? 'Uploaded.'
                    : 'The browser file upload was refused by its file policy.',
                isError: !approved,
              ),
              'toolset_name': 'browser',
            },
          ],
        });
      }
      expect(seen, ['policy', 'confirm', 'run']);
    },
  );

  test('closed client cannot dispatch an approved toolset action', () async {
    final browser = RunnableMessageToolset(
      definition: BuiltInTool.browserToolset(),
      confirm: (_, _) {
        client.close();
        return true;
      },
      run: (_, _) => fail('Closed client ran the toolset callback.'),
    );
    httpClient.queueJsonResponse(
      _reply('msg_tools', 'tool_use', [
        _toolsetUse('screenshot', 'browser', 'screenshot'),
      ]),
    );
    await expectLater(
      client.messages.runTools(request, tools: [], toolsets: [browser]),
      throwsStateError,
    );
    expect(httpClient.requests, hasLength(1));
  });

  test(
    'inline removal and re-addition govern a registered toolset family',
    () async {
      const remove = ToolRemovalInputBlock(
        tool: ToolChangeToolReference('browser'),
      );
      const add = ToolAdditionInputBlock(
        tool: ToolChangeToolReference('browser'),
      );
      var runs = 0;
      final browser = RunnableMessageToolset(
        definition: BuiltInTool.browserToolset(),
        run: (_, _) {
          runs++;
          return MessageToolResult.text('Ran fixture action.');
        },
      );
      for (final restored in [false, true]) {
        httpClient
          ..queueJsonResponse(
            _reply('msg_tools', 'tool_use', [
              _toolsetUse('read', 'browser', 'read_page'),
            ]),
          )
          ..queueJsonResponse(MockResponses.message());
        await client.messages.runTools(
          request.copyWith(
            model: 'claude-sonnet-5-5',
            messages: [
              ...request.messages,
              InputMessage(
                role: MessageRole.system,
                content: MessageContent.blocks([remove, if (restored) add]),
              ),
            ],
          ),
          tools: [],
          toolsets: [browser],
          betas: ['inline-tools-2026-09-15'],
        );
        final messages =
            _body(httpClient.lastRequest!)['messages'] as List<Object?>;
        expect(messages.last, {
          'role': 'user',
          'content': [
            {
              ..._result(
                'read',
                restored
                    ? 'Ran fixture action.'
                    : 'The requested tool has no available callback.',
                isError: !restored,
              ),
              'toolset_name': 'browser',
            },
          ],
        });
      }
      expect(runs, 1);
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

  test('on-demand compaction trims only the summary request', () async {
    const format = JsonOutputFormat(schema: {'type': 'object'});
    const output = OutputConfig(effort: EffortLevel.low, format: format);
    final configured = request.copyWith(
      model: 'claude-sonnet-5-5',
      stopSequences: ['the end'],
      toolChoice: const ToolChoiceAny(),
      outputConfig: output,
      contextManagement: const ContextManagementConfig(
        edits: [ClearToolUsesEdit()],
      ),
      fallbacks: const FallbacksParam.list([
        FallbackConfigV2(model: 'claude-opus-5-5', outputConfig: output),
      ]),
    );
    const summary = {
      'type': 'compaction',
      'content': 'Signed summary',
      'encrypted_content': null,
      'signature': 'signature-fixture',
      'tool_changes': <Object>[],
    };

    httpClient
      ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
      ..queueJsonResponse(_reply('msg_summary', 'compaction', [summary]))
      ..queueJsonResponse(MockResponses.message(id: 'msg_final'));
    final result = await client.messages.runTools(
      configured,
      tools: [_calculator((_, _) => MessageToolResult.text('6'))],
      maxIterations: 2,
      compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
      betas: ['compact-2026-09-04', 'inline-tools-2026-09-15'],
      workspaceId: 'wrk_fixture',
    );
    expect(result.iterations, 2);
    expect(result.compactionMessage!.id, 'msg_summary');
    expect(result.message.id, 'msg_final');
    expect(httpClient.requests, hasLength(3));
    final sidecar = _body(httpClient.requests[1]);
    expect(
      httpClient.requests[1].headers['anthropic-workspace-id'],
      'wrk_fixture',
    );
    expect(
      httpClient.requests[1].headers['anthropic-beta'],
      'compact-2026-09-04,inline-tools-2026-09-15',
    );
    expect(sidecar['compaction'], {'type': 'summarize'});
    expect(sidecar, isNot(contains('context_management')));
    expect(sidecar, isNot(contains('tool_choice')));
    expect(sidecar, isNot(contains('stop_sequences')));
    expect(sidecar, isNot(contains('thread')));
    expect(sidecar['output_config'], {'effort': 'low'});
    expect(sidecar['fallbacks'], [
      {
        'model': 'claude-opus-5-5',
        'output_config': {'effort': 'low'},
      },
    ]);
    expect(sidecar['messages'], [
      configured.messages.single.toJson(),
      {
        'role': 'assistant',
        'content': [_toolUse('one')],
      },
      {
        'role': 'user',
        'content': [_result('one', '6')],
      },
    ]);
    final followUp = _body(httpClient.lastRequest!);
    expect(followUp['messages'], [
      {
        'role': 'assistant',
        'content': [summary],
      },
    ]);
    expect(followUp['output_config'], output.toJson());
    expect(followUp['fallbacks'], configured.fallbacks!.toJson());
    expect(followUp['stop_sequences'], ['the end']);
    expect(
      followUp['context_management'],
      configured.contextManagement!.toJson(),
    );
    expect(followUp, isNot(contains('compaction')));
    expect(followUp, isNot(contains('thread')));
    expect(result.thread, isNull);
  });

  test('streamed compaction replays the complete signed start block', () async {
    final block = <String, dynamic>{
      'type': 'compaction',
      'content': 'Summary',
      'encrypted_content': 'opaque-untouched',
      'signature': 'signed',
    };
    final summary = MockResponses.streamingEvents(id: 'msg_summary')
      ..[1] = {
        'type': 'content_block_start',
        'index': 0,
        'content_block': block,
      }
      ..removeAt(2)
      ..[3] = {
        'type': 'message_delta',
        'delta': {'stop_reason': 'compaction'},
        'usage': {'output_tokens': 10},
      };
    httpClient
      ..queueStreamingResponse(_toolEvents())
      ..queueStreamingResponse(summary)
      ..queueStreamingResponse(MockResponses.streamingEvents());
    final observed = <MessageStreamEvent>[];
    final result = await client.messages.runTools(
      request,
      tools: [_calculator((_, _) => MessageToolResult.text('6'))],
      compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
      betas: ['compact-2026-09-04'],
      onEvent: observed.add,
    );
    expect(result.compactionMessage!.content.single.toJson(), block);
    expect(observed.whereType<MessageStopEvent>(), hasLength(3));
    expect(_body(httpClient.requests[1])['stream'], isTrue);
    expect(_body(httpClient.lastRequest!)['messages'], [
      {
        'role': 'assistant',
        'content': [block],
      },
    ]);
  });

  test('unsigned summary leaves the original replay available', () async {
    httpClient
      ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
      ..queueJsonResponse(
        _reply('msg_summary', 'compaction', [
          {
            'type': 'compaction',
            'content': 'unsigned',
            'encrypted_content': null,
          },
        ]),
      )
      ..queueJsonResponse(MockResponses.message());
    final result = await client.messages.runTools(
      request,
      tools: [_calculator((_, _) => MessageToolResult.text('6'))],
      compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
      betas: ['compact-2026-09-04'],
    );
    expect(result.compactionMessage!.id, 'msg_summary');
    expect(_body(httpClient.lastRequest!)['messages'], [
      request.messages.single.toJson(),
      {
        'role': 'assistant',
        'content': [_toolUse('one')],
      },
      {
        'role': 'user',
        'content': [_result('one', '6')],
      },
    ]);
  });

  test('signed summary must retain the prior tool availability', () async {
    const removed = ToolRemovalInputBlock(
      tool: ToolChangeToolReference('calculate'),
    );
    final input = request.copyWith(
      model: 'claude-sonnet-5-5',
      messages: [
        ...request.messages,
        InputMessage(
          role: MessageRole.system,
          content: MessageContent.blocks([removed]),
        ),
      ],
    );
    for (final carriesChanges in [false, true]) {
      final summary = {
        'type': 'compaction',
        'content': 'Summary',
        'signature': 'signed',
        if (carriesChanges) 'tool_changes': [removed.toJson()],
      };
      httpClient
        ..reset()
        ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
        ..queueJsonResponse(_reply('msg_summary', 'compaction', [summary]))
        ..queueJsonResponse(
          _reply('msg_more_tools', 'tool_use', [_toolUse('two')]),
        )
        ..queueJsonResponse(MockResponses.message());
      final result = await client.messages.runTools(
        input,
        tools: [
          _calculator((_, _) => fail('Removed callback ran after summary.')),
        ],
        compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
        betas: ['compact-2026-09-04', 'inline-tools-2026-09-15'],
      );
      expect(result.compactionMessage!.id, 'msg_summary');
      final messages = _body(httpClient.requests[2])['messages'] as List;
      if (carriesChanges) {
        expect(messages, [
          {
            'role': 'assistant',
            'content': [summary],
          },
        ]);
      } else {
        expect(messages, hasLength(4));
        expect(messages[1], input.messages.last.toJson());
      }
      final followUp = _body(httpClient.requests[3])['messages'] as List;
      expect(followUp.last, {
        'role': 'user',
        'content': [
          _result(
            'two',
            'The requested tool has no available callback.',
            isError: true,
          ),
        ],
      });
    }
  });

  test(
    'signed compaction rejects server-held threads before any work',
    () async {
      await expectLater(
        client.messages.runTools(
          request,
          tools: [_calculator((_, _) => fail('Unexpected tool callback.'))],
          useThread: true,
          compactBeforeNextTurn: (_) => fail('Unexpected compaction selector.'),
          onTurn: (_) => fail('Unexpected turn callback.'),
          betas: ['compact-2026-09-04'],
        ),
        throwsArgumentError,
      );
      expect(httpClient.requests, isEmpty);
    },
  );

  test(
    'scheduled compaction preserves the abort boundary before tools',
    () async {
      final abort = Completer<void>();
      httpClient.queueJsonResponse(
        _reply('msg_tools', 'tool_use', [_toolUse('one')]),
      );
      await expectLater(
        client.messages.runTools(
          request,
          tools: [_calculator((_, _) => fail('Aborted tool callback.'))],
          compactBeforeNextTurn: (_) {
            abort.complete();
            return const CompactionConfig.summarize();
          },
          abortTrigger: abort.future,
          betas: ['compact-2026-09-04'],
        ),
        throwsA(isA<AbortedException>()),
      );
      expect(httpClient.requests, hasLength(1));
    },
  );

  test(
    'malformed tool IDs prevent scheduling or executing compaction',
    () async {
      httpClient.queueJsonResponse(
        _reply('msg_tools', 'tool_use', [_toolUse('bad id')]),
      );
      await expectLater(
        client.messages.runTools(
          request,
          tools: [_calculator((_, _) => fail('Invalid tool callback.'))],
          compactBeforeNextTurn: (_) => fail('Invalid compaction selector.'),
          betas: ['compact-2026-09-04'],
        ),
        throwsFormatException,
      );
      expect(httpClient.requests, hasLength(1));
    },
  );

  test(
    'compaction rejects primary and fallback task budget remainders',
    () async {
      const budget = OutputConfig(
        taskBudget: TokenTaskBudget(total: 24000, remaining: 22000),
      );
      final requests = [
        request.copyWith(outputConfig: budget),
        request.copyWith(
          fallbacks: const FallbacksParam.list([
            FallbackConfigV2(model: 'claude-opus-5-5', outputConfig: budget),
          ]),
        ),
      ];
      for (final configured in requests) {
        httpClient.queueJsonResponse(
          _reply('msg_tools', 'tool_use', [_toolUse('one')]),
        );
        await expectLater(
          client.messages.runTools(
            configured,
            tools: [_calculator((_, _) => fail('Unexpected tool callback.'))],
            compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
            betas: ['compact-2026-09-04', 'task-budgets-2026-03-13'],
          ),
          throwsArgumentError,
        );
      }
      expect(httpClient.requests, hasLength(2));
    },
  );

  test('invalid compaction combinations fail before local callbacks', () async {
    final tool = _calculator((_, _) => fail('Unexpected callback.'));
    httpClient.queueJsonResponse(
      _reply('msg_tools', 'tool_use', [_toolUse('one')]),
    );
    await expectLater(
      client.messages.runTools(
        request,
        tools: [tool],
        compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
      ),
      throwsArgumentError,
    );
    httpClient.queueJsonResponse(
      _reply('msg_tools', 'tool_use', [_toolUse('one')]),
    );
    await expectLater(
      client.messages.runTools(
        request.copyWith(
          contextManagement: const ContextManagementConfig(
            edits: [ThresholdCompactionEdit()],
          ),
        ),
        tools: [tool],
        compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
        betas: ['compact-2026-09-04', 'compact-2026-01-12'],
      ),
      throwsArgumentError,
    );
    expect(httpClient.requests, hasLength(2));
  });

  test(
    'pending on-demand compaction waits for a completed tool turn',
    () async {
      httpClient
        ..queueJsonResponse(MockResponses.message(stopReason: 'pause_turn'))
        ..queueJsonResponse(_reply('msg_tools', 'tool_use', [_toolUse('one')]))
        ..queueJsonResponse(
          _reply('msg_summary', 'compaction', [
            {'type': 'compaction', 'content': 'summary', 'signature': 'signed'},
          ]),
        )
        ..queueJsonResponse(MockResponses.message());
      final result = await client.messages.runTools(
        request,
        tools: [_calculator((_, _) => MessageToolResult.text('6'))],
        compactBeforeNextTurn: (message) =>
            message.stopReason == StopReason.pauseTurn
            ? const CompactionConfig.summarize()
            : null,
        betas: ['compact-2026-09-04'],
      );
      expect(result.iterations, 3);
      expect(_body(httpClient.requests[1]), isNot(contains('compaction')));
      expect(_body(httpClient.requests[2])['compaction'], {
        'type': 'summarize',
      });
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

Map<String, dynamic> _toolsetUse(
  String id,
  String family,
  String name, [
  Map<String, Object?> input = const {},
]) => {
  'type': 'tool_use',
  'id': id,
  'toolset_name': family,
  'name': name,
  'input': input,
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
