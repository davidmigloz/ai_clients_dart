// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Run with ANTHROPIC_API_KEY set on a platform that supports browser use.
/// This callback uses a stub browser and returns only fixture data.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  final browser = RunnableMessageToolset(
    definition: BuiltInTool.browserToolset(),
    run: (action, call) {
      print('Browser call ${call.toolUse.id}');
      final String text;
      switch (action) {
        case BrowserNavigateAction(url: 'https://example.com'):
          text = 'Navigated to https://example.com in the stub browser.';
        case BrowserReadPageAction():
          text = 'Example Domain. This page is used for examples.';
        default:
          return MessageToolResult.text(
            'This action is unavailable in the stub browser.',
            isError: true,
          );
      }
      return MessageToolResult([
        ToolResultContent.text(text),
        ToolResultContent.browserState(
          tabs: const [
            BrowserStateTabEntry(
              tabId: 'tab_example',
              title: 'Example Domain',
              url: 'https://example.com',
              active: true,
            ),
          ],
        ),
      ]);
    },
  );

  try {
    final result = await client.messages.runTools(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 512,
        messages: [
          InputMessage.user(
            'Visit https://example.com and summarize the page.',
          ),
        ],
      ),
      tools: [],
      toolsets: [browser],
      maxIterations: 4,
    );
    print(result.message.text);
  } finally {
    client.close();
  }
}
