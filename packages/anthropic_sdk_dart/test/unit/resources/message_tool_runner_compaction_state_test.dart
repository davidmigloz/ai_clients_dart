import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const Tool _tool = Tool(name: 'calculate', inputSchema: InputSchema());
const Map<String, Object> _call = {
  'type': 'tool_use',
  'id': 'toolu_fixture',
  'name': 'calculate',
  'input': <String, dynamic>{},
};

InputMessage _remove(String name) => InputMessage(
  role: MessageRole.system,
  content: MessageContent.blocks([
    ToolRemovalInputBlock(tool: ToolChangeToolReference(name)),
  ]),
);

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;
  late RunnableMessageTool<int> runnable;
  late int callbacks;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient.withApiKey('fixture', httpClient: transport);
    addTearDown(client.close);
    callbacks = 0;
    runnable = RunnableMessageTool<int>(
      definition: _tool,
      decode: (_) => 1,
      run: (_, _) {
        callbacks++;
        return MessageToolResult.text('side effect');
      },
    );
  });

  test(
    'a failed threshold summary cannot re-enable a removed callback',
    () async {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 1024,
        contextManagement: const ContextManagementConfig(
          edits: [ThresholdCompactionEdit()],
        ),
        messages: [InputMessage.user('Use a tool.'), _remove('calculate')],
      );
      final failed = {
        'type': 'compaction',
        'content': null,
        'encrypted_content': null,
        'tool_changes': [
          {
            'type': 'tool_addition',
            'tool': {'type': 'tool_reference', 'name': 'calculate'},
          },
        ],
      };
      transport
        ..queueJsonResponse({
          ...MockResponses.message(stopReason: 'tool_use'),
          'content': [failed, _call],
        })
        ..queueJsonResponse(MockResponses.message(text: 'complete'));
      await client.messages.runTools(
        request,
        tools: [runnable],
        betas: ['compact-2026-01-12', 'inline-tools-2026-09-15'],
      );
      expect(callbacks, 0);
      final messages = _messages(transport);
      final content = (messages.last['content'] as List<Object?>)
          .cast<Map<String, dynamic>>();
      expect(content.single['is_error'], isTrue);
    },
  );

  test(
    'a summary cannot drop an explicitly removed non-callback server tool',
    () async {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 1024,
        tools: [ToolDefinition.builtIn(BuiltInTool.webSearch())],
        messages: [
          InputMessage.user('Use only the local tool.'),
          _remove('web_search'),
        ],
      );
      final signed = {
        'type': 'compaction',
        'content': 'summary',
        'signature': 'signed',
        'tool_changes': <Object>[],
      };
      transport
        ..queueJsonResponse({
          ...MockResponses.message(stopReason: 'tool_use'),
          'content': [_call],
        })
        ..queueJsonResponse({
          ...MockResponses.message(stopReason: 'compaction'),
          'content': [signed],
        })
        ..queueJsonResponse(MockResponses.message(text: 'complete'));
      final result = await client.messages.runTools(
        request,
        tools: [runnable],
        compactBeforeNextTurn: (_) => const CompactionConfig.summarize(),
        betas: ['compact-2026-09-04', 'inline-tools-2026-09-15'],
      );
      expect(result.message.text, 'complete');
      expect(callbacks, 1);
      expect(_messages(transport)[1], request.messages.last.toJson());
    },
  );
}

List<Map<String, dynamic>> _messages(MockHttpClient transport) {
  final request = transport.requests.last as http.Request;
  final body = jsonDecode(request.body) as Map<String, dynamic>;
  return (body['messages'] as List<Object?>).cast<Map<String, dynamic>>();
}
