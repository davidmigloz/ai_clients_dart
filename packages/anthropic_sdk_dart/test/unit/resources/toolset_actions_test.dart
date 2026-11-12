import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _cases = <(String, String, Map<String, dynamic>, Type)>[
  (
    'browser',
    'navigate',
    {'url': 'https://example.invalid'},
    BrowserNavigateAction,
  ),
  ('browser', 'list_tabs', {}, BrowserListTabsAction),
  ('browser', 'new_tab', {}, BrowserNewTabAction),
  ('browser', 'switch_tab', {'tab_id': 'tab_fixture'}, BrowserSwitchTabAction),
  ('browser', 'close_tab', {'tab_id': 'tab_fixture'}, BrowserCloseTabAction),
  ('browser', 'read_page', {}, BrowserReadPageAction),
  ('browser', 'get_page_text', {}, BrowserGetPageTextAction),
  ('browser', 'read_console', {}, BrowserReadConsoleAction),
  ('browser', 'read_network', {}, BrowserReadNetworkAction),
  ('browser', 'find', {'query': 'fixture'}, BrowserFindAction),
  (
    'browser',
    'form_input',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
      'value': true,
    },
    BrowserFormInputAction,
  ),
  (
    'browser',
    'file_upload',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
      'document_ids': ['file_fixture'],
    },
    BrowserFileUploadAction,
  ),
  (
    'browser',
    'scroll_to',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserScrollToAction,
  ),
  ('browser', 'screenshot', {}, BrowserScreenshotAction),
  (
    'browser',
    'zoom',
    {
      'region': [0, 1, 2, 3],
    },
    BrowserZoomAction,
  ),
  (
    'browser',
    'left_click',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserLeftClickAction,
  ),
  (
    'browser',
    'right_click',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserRightClickAction,
  ),
  (
    'browser',
    'middle_click',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserMiddleClickAction,
  ),
  (
    'browser',
    'double_click',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserDoubleClickAction,
  ),
  (
    'browser',
    'triple_click',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserTripleClickAction,
  ),
  (
    'browser',
    'hover',
    {
      'target': {'type': 'ref', 'ref': 'ref_1'},
    },
    BrowserHoverAction,
  ),
  (
    'browser',
    'left_click_drag',
    {
      'from': {'type': 'coordinate', 'x': 5, 'y': 9},
      'target': {'type': 'coordinate', 'x': 5, 'y': 9},
    },
    BrowserLeftClickDragAction,
  ),
  (
    'browser',
    'left_mouse_down',
    {
      'target': {'type': 'coordinate', 'x': 5, 'y': 9},
    },
    BrowserLeftMouseDownAction,
  ),
  (
    'browser',
    'left_mouse_up',
    {
      'target': {'type': 'coordinate', 'x': 5, 'y': 9},
    },
    BrowserLeftMouseUpAction,
  ),
  (
    'browser',
    'mouse_move',
    {
      'target': {'type': 'coordinate', 'x': 5, 'y': 9},
    },
    BrowserMouseMoveAction,
  ),
  (
    'browser',
    'scroll',
    {
      'scroll_direction': 'down',
      'target': {'type': 'coordinate', 'x': 5, 'y': 9},
    },
    BrowserScrollAction,
  ),
  ('browser', 'type', {'text': 'fixture'}, BrowserTypeAction),
  ('browser', 'key', {'text': 'fixture'}, BrowserKeyAction),
  (
    'browser',
    'hold_key',
    {'duration': 5, 'text': 'fixture'},
    BrowserHoldKeyAction,
  ),
  ('browser', 'wait', {'duration': 5}, BrowserWaitAction),
  (
    'browser',
    'javascript_exec',
    {'text': 'fixture'},
    BrowserJavascriptExecAction,
  ),
  ('computer', 'key', {'text': 'fixture'}, ComputerKeyAction),
  (
    'computer',
    'hold_key',
    {'duration': 5, 'text': 'fixture'},
    ComputerHoldKeyAction,
  ),
  ('computer', 'type', {'text': 'fixture'}, ComputerTypeAction),
  ('computer', 'cursor_position', {}, ComputerCursorPositionAction),
  (
    'computer',
    'mouse_move',
    {
      'coordinate': [0, 1],
    },
    ComputerMouseMoveAction,
  ),
  ('computer', 'left_mouse_down', {}, ComputerLeftMouseDownAction),
  ('computer', 'left_mouse_up', {}, ComputerLeftMouseUpAction),
  ('computer', 'left_click', {}, ComputerLeftClickAction),
  (
    'computer',
    'left_click_drag',
    {
      'coordinate': [0, 1],
      'start_coordinate': [0, 1],
    },
    ComputerLeftClickDragAction,
  ),
  ('computer', 'right_click', {}, ComputerRightClickAction),
  ('computer', 'middle_click', {}, ComputerMiddleClickAction),
  ('computer', 'double_click', {}, ComputerDoubleClickAction),
  ('computer', 'triple_click', {}, ComputerTripleClickAction),
  (
    'computer',
    'scroll',
    {'scroll_amount': 5, 'scroll_direction': 'up'},
    ComputerScrollAction,
  ),
  ('computer', 'wait', {'duration': 5}, ComputerWaitAction),
  ('computer', 'screenshot', {}, ComputerScreenshotAction),
  (
    'computer',
    'zoom',
    {
      'region': [0, 1, 2, 3],
    },
    ComputerZoomAction,
  ),
];

Map<String, dynamic> _tool(
  String family,
  String name,
  Map<String, dynamic> input,
) => {
  'type': 'tool_use',
  'id': 'toolu_fixture',
  'caller': {'type': 'direct'},
  'toolset_name': family,
  'name': name,
  'input': input,
};

void main() {
  for (final (family, name, input, type) in _cases) {
    test('$family $name is typed and preserves request replay', () {
      final json = _tool(family, name, input);
      final block = ContentBlock.fromJson(json) as ToolUseBlock;
      final action = block.toolsetAction!;
      expect(action.runtimeType, type);
      expect(action.input, input);
      expect(block.toJson(), json);
      final replay = block.toInputBlock() as ToolUseInputBlock;
      expect(replay.toolsetAction, action);
      expect(replay.toolsetAction.hashCode, action.hashCode);
      expect(replay.toJson(), json);
    });
  }

  test('custom and future calls keep their original payload', () {
    final json = _tool('browser', 'future_action', {
      'options': {
        'values': [1, 2],
      },
    });
    final custom = ToolUseBlock.fromJson(Map.of(json)..remove('toolset_name'));
    expect(custom.toolsetAction, isNull);
    final action = ToolUseBlock.fromJson(json).toolsetAction!;
    expect(action, isA<UnknownToolsetAction>());
    expect(ToolsetAction.fromJson(action.toJson()), action);
    expect(
      () => action.input['options'] = <String, Object?>{},
      throwsUnsupportedError,
    );
    expect(action.input, json['input']);
  });

  test(
    'typed browser targets and form values use their wire discriminators',
    () {
      final click =
          ToolsetAction.decode('browser', 'left_click', const {
                'target': {'type': 'coordinate', 'x': 12, 'y': 34},
                'tab_id': 'tab_fixture',
                'modifiers': 'ctrl',
              })
              as BrowserLeftClickAction;
      final coordinate = click.target as BrowserCoordinateTarget;
      expect((coordinate.x, coordinate.y), (12, 34));
      expect(click.tabId, 'tab_fixture');
      expect(click.modifiers, 'ctrl');
      final form =
          ToolsetAction.decode('browser', 'form_input', const {
                'target': {'type': 'ref', 'ref': 'ref_7'},
                'value': true,
              })
              as BrowserFormInputAction;
      expect(form.target.ref, 'ref_7');
      expect(form.value, const BrowserBooleanFormValue(value: true));
      expect(BrowserFormValue.fromJson(4.5), const BrowserNumberFormValue(4.5));
      expect(
        BrowserFormValue.fromJson('text'),
        const BrowserTextFormValue('text'),
      );
      final future =
          ToolsetAction.decode('browser', 'hover', const {
                'target': {'type': 'future_target', 'payload': 9},
              })
              as BrowserHoverAction;
      expect(future.target, isA<UnknownBrowserClickTarget>());
      expect(future.target.toJson(), {'type': 'future_target', 'payload': 9});
    },
  );

  test(
    'SSE assembles tool input and preserves reply without a GA beta',
    () async {
      final initial = _tool('browser', 'navigate', {});
      final events = MockResponses.streamingEvents();
      events[1] = {
        'type': 'content_block_start',
        'index': 0,
        'content_block': initial,
      };
      events[2] = {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {
          'type': 'input_json_delta',
          'partial_json': '{"tab_id":"tab_1",',
        },
      };
      events.insert(3, {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {
          'type': 'input_json_delta',
          'partial_json': '"url":"https://example.invalid"}',
        },
      });
      final transport = MockHttpClient()
        ..queueStreamingResponse(events)
        ..queueJsonResponse(MockResponses.message());
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 64,
        messages: [InputMessage.user('Open the example page')],
        tools: [ToolDefinition.builtIn(BuiltInTool.browserToolset())],
      );
      final message = await client.messages
          .createStream(request)
          .finalMessage();
      final tool = message.toolUseBlocks.single;
      final navigate = tool.toolsetAction! as BrowserNavigateAction;
      expect(navigate.tabId, 'tab_1');
      expect(navigate.url, 'https://example.invalid');
      await client.messages.create(
        request.copyWith(
          messages: [
            ...request.messages,
            message.toInputMessage(),
            InputMessage.userBlocks([
              InputContentBlock.toolResult(
                toolUseId: tool.id,
                toolsetName: tool.toolsetName,
                content: [ToolResultContent.text('Opened the page.')],
              ),
            ]),
          ],
        ),
      );
      for (final sent in transport.requests) {
        expect(sent.headers['anthropic-beta'], isNull);
      }
      final sent = transport.requests.last as http.Request;
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['tools'], [
        {'type': 'browser_toolset_20260801'},
      ]);
      final messages = body['messages'] as List<dynamic>;
      expect(messages[1], {
        'role': 'assistant',
        'content': [tool.toJson()],
      });
      expect(messages[2], {
        'role': 'user',
        'content': [
          {
            'type': 'tool_result',
            'tool_use_id': 'toolu_fixture',
            'toolset_name': 'browser',
            'content': [
              {'type': 'text', 'text': 'Opened the page.'},
            ],
          },
        ],
      });
    },
  );
}
