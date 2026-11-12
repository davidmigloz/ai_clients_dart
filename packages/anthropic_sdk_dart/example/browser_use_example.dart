// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Browser toolset example.
///
/// This example demonstrates the browser toolset
/// ([BuiltInTool.browserToolset]) — a client toolset for a browser your
/// application hosts. Claude drives it via member tool calls (`navigate`,
/// `screenshot`, `read_page`, etc.), and your application executes each
/// action against a real (or virtual) browser and reports the result,
/// including a `browser_state` block describing the caller's open tabs and
/// any side effects (tabs opened, downloads) the call produced.
///
/// This example uses a stub browser that fakes `navigate`, `screenshot`, and
/// `read_page` handlers instead of driving a real one.
/// Set ANTHROPIC_API_KEY before running.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    // The browser toolset carries no `name` — it's a single `tools[]` entry
    // declaring the whole family. Every member is enabled by default.
    final tools = [ToolDefinition.builtIn(BuiltInTool.browserToolset())];

    var messages = <InputMessage>[
      InputMessage.user(
        'Navigate to example.com and tell me what the page says.',
      ),
    ];

    while (true) {
      final response = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-5-5',
          maxTokens: 4096,
          tools: tools,
          messages: messages,
        ),
      );

      if (!response.isToolUse) {
        print('Claude: ${response.text}');
        break;
      }

      messages = [...messages, response.toInputMessage()];

      final results = <ToolResultInputBlock>[];
      for (final toolUse in response.toolUseBlocks) {
        final action = toolUse.toolsetAction;
        print(
          'Browser toolset action: ${toolUse.name} '
          '(toolset: ${toolUse.toolsetName})',
        );

        // Execute the action against the stub browser, then report the page
        // text (or acknowledgement) alongside a `browser_state` block
        // describing the caller's open tabs after the call.
        final content = <ToolResultContent>[
          switch (action) {
            BrowserNavigateAction(:final url) => ToolResultContent.text(
              'Navigated to $url.',
            ),
            BrowserReadPageAction() => ToolResultContent.text(
              'Example Domain\nThis domain is for use in illustrative '
              'examples.',
            ),
            BrowserNewTabAction() => ToolResultContent.text(
              'Opened a stub tab.',
            ),
            BrowserScreenshotAction() => ToolResultContent.text(
              '[stub screenshot of the current page]',
            ),
            _ => ToolResultContent.text(
              'The stub does not execute this action.',
            ),
          },
          ToolResultContent.browserState(
            tabs: const [
              BrowserStateTabEntry(
                tabId: 'tab_1',
                title: 'Example Domain',
                url: 'https://example.com',
                active: true,
              ),
            ],
            // "Nothing to report" is expressed by omitting `stateChanges`
            // entirely; report `tab_opened` only when this call opened one.
            stateChanges: action is BrowserNewTabAction
                ? const [BrowserStateChangeTabOpened(tabId: 'tab_1')]
                : null,
          ),
        ];

        results.add(
          ToolResultInputBlock(
            toolUseId: toolUse.id,
            content: content,
            isError:
                action is! BrowserNavigateAction &&
                action is! BrowserReadPageAction &&
                action is! BrowserNewTabAction &&
                action is! BrowserScreenshotAction,
            toolsetName: toolUse.toolsetName,
          ),
        );
      }

      messages = [...messages, InputMessage.userBlocks(results)];
    }
  } finally {
    client.close();
  }
}
