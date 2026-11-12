import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('malformed browser batch halts later browser members', () async {
    final calls = <String>[];
    final requests = <Map<String, dynamic>>[];
    final client = _client(requests, [
      {
        'type': 'tool_use',
        'id': 'toolu_malformed',
        'name': 'browser',
        'input': {
          'actions': [
            {'action': 'navigate'},
          ],
        },
      },
      _use('toolu_browser', 'browser', 'navigate', {
        'url': 'https://example.com',
      }),
      _use('toolu_computer', 'computer', 'screenshot'),
    ]);
    addTearDown(client.close);
    final browser = RunnableMessageToolset(
      definition: BuiltInTool.browserToolset(),
      run: (action, call) {
        calls.add(call.toolUse.id);
        return MessageToolResult.text('Browser executed.');
      },
    );
    final computer = RunnableMessageToolset(
      definition: BuiltInTool.computerToolset(),
      confirm: (_, _) => true,
      run: (action, call) {
        calls.add(call.toolUse.id);
        return MessageToolResult.text('Computer executed.');
      },
    );
    await client.messages.runTools(
      _request(),
      tools: [],
      toolsets: [browser, computer],
    );
    expect(calls, ['toolu_computer']);
    final results = _results(requests);
    expect(results.map((result) => result['tool_use_id']), [
      'toolu_malformed',
      'toolu_browser',
      'toolu_computer',
    ]);
    expect(results.first, containsPair('is_error', true));
    expect(results.first, isNot(contains('toolset_name')));
    expect(results[1], containsPair('toolset_name', 'browser'));
    expect(results[1], containsPair('is_error', true));
    expect(results[1]['content'], [
      {
        'type': 'text',
        'text': 'Not executed: an earlier action in this turn failed.',
      },
    ]);
    expect(results[2], containsPair('toolset_name', 'computer'));
  });

  test(
    'inline replacement does not leave an obsolete JavaScript executor available',
    () async {
      var confirmations = 0;
      var executions = 0;
      final requests = <Map<String, dynamic>>[];
      final client = _client(requests, [
        _use('toolu_script', 'browser', 'javascript_exec', {
          'text': 'window.location.href',
        }),
      ]);
      addTearDown(client.close);
      final browser = RunnableMessageToolset(
        definition: BuiltInTool.browserToolset(
          configs: const BrowserToolsetConfigs(
            javascriptExec: ToolsetMemberConfig(enabled: true),
          ),
        ),
        confirm: (_, _) {
          confirmations++;
          return true;
        },
        run: (_, _) {
          executions++;
          return MessageToolResult.text('Stale executor ran.');
        },
      );
      final replacement = ToolAdditionInputBlock(
        tool: ToolChangeInlineDefinition(
          ToolDefinition.builtIn(BuiltInTool.browserToolset()),
        ),
      );
      await client.messages.runTools(
        _request(replacement),
        tools: [],
        toolsets: [browser],
        betas: ['inline-tools-2026-09-15'],
      );
      expect((confirmations, executions), (0, 0));
      expect(_results(requests).single, containsPair('is_error', true));
      final messages = requests.first['messages'] as List<Object?>;
      final last = messages.last! as Map<String, dynamic>;
      expect(last['content'], [replacement.toJson()]);
    },
  );
}

MessageCreateRequest _request([InputContentBlock? change]) =>
    MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 128,
      messages: [
        InputMessage.user('Use browser and computer fixtures.'),
        if (change != null)
          InputMessage(
            role: MessageRole.system,
            content: MessageContent.blocks([change]),
          ),
      ],
    );

AnthropicClient _client(
  List<Map<String, dynamic>> requests,
  List<Map<String, dynamic>> calls,
) => AnthropicClient.withApiKey(
  'fixture',
  httpClient: MockClient((request) async {
    requests.add(jsonDecode(request.body) as Map<String, dynamic>);
    return http.Response(
      jsonEncode({
        'type': 'message',
        'id': 'msg_${requests.length}',
        'role': 'assistant',
        'model': 'claude-sonnet-5-5',
        'stop_reason': requests.length == 1 ? 'tool_use' : 'end_turn',
        'stop_sequence': null,
        'usage': {'input_tokens': 1, 'output_tokens': 1},
        'content': requests.length == 1
            ? calls
            : [
                {'type': 'text', 'text': 'done'},
              ],
      }),
      200,
    );
  }),
);

Map<String, dynamic> _use(
  String id,
  String family,
  String name, [
  Map<String, dynamic> input = const {},
]) => {
  'type': 'tool_use',
  'id': id,
  'name': name,
  'toolset_name': family,
  'input': input,
};

List<Map<String, dynamic>> _results(List<Map<String, dynamic>> requests) {
  expect(requests, hasLength(2));
  final last = (requests.last['messages'] as List).last as Map<String, dynamic>;
  return (last['content'] as List).cast<Map<String, dynamic>>();
}
