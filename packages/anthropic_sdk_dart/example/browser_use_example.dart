// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

// A 1x1 transparent PNG used as a stand-in for a screenshot.
const _stubScreenshotBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42'
    'YAAAAASUVORK5CYII=';

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
/// The stub browser handles navigation, screenshots, reading, and opening tabs.
/// Set ANTHROPIC_API_KEY before running.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();

  try {
    // One tools entry declares the browser family. File upload, JavaScript,
    // console reads, and network reads require explicit enablement.
    final tools = [ToolDefinition.builtIn(BuiltInTool.browserToolset())];
    var tabs = <BrowserStateTabEntry>[
      const BrowserStateTabEntry(
        tabId: 'tab_1',
        title: '',
        url: 'about:blank',
        active: true,
      ),
    ];

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

        final List<ToolResultContent> content;
        var isError = false;
        switch (action) {
          case BrowserNavigateAction(:final url, :final tabId):
            final targetId =
                tabId ?? tabs.firstWhere((tab) => tab.active).tabId;
            if (!tabs.any((tab) => tab.tabId == targetId)) {
              content = [ToolResultContent.text('Unknown tab $targetId.')];
              isError = true;
              break;
            }
            tabs = [
              for (final tab in tabs)
                if (tab.tabId == targetId)
                  tab.copyWith(url: url, title: 'Example Domain')
                else
                  tab,
            ];
            content = [
              ToolResultContent.text('Navigated to $url.'),
              ToolResultContent.browserState(tabs: tabs),
            ];
          case BrowserReadPageAction():
            content = [
              ToolResultContent.text(
                'Example Domain\nThis domain is for use in illustrative examples.',
              ),
              ToolResultContent.browserState(tabs: tabs),
            ];
          case BrowserNewTabAction():
            final newTabId = 'tab_${tabs.length + 1}';
            tabs = [
              for (final tab in tabs) tab.copyWith(active: false),
              BrowserStateTabEntry(
                tabId: newTabId,
                title: '',
                url: 'about:blank',
                active: true,
              ),
            ];
            // Successful tab management returns one browser_state block.
            content = [
              ToolResultContent.browserState(
                tabs: tabs,
                stateChanges: [BrowserStateChangeTabOpened(tabId: newTabId)],
              ),
            ];
          case BrowserScreenshotAction():
            content = [
              ToolResultContent.image(
                ImageSource.base64(
                  data: _stubScreenshotBase64,
                  mediaType: ImageMediaType.png,
                ),
              ),
              ToolResultContent.browserState(tabs: tabs),
            ];
          case _:
            content = [
              ToolResultContent.text('Unsupported action in this stub.'),
            ];
            isError = true;
        }

        results.add(
          ToolResultInputBlock(
            toolUseId: toolUse.id,
            content: content,
            isError: isError,
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
