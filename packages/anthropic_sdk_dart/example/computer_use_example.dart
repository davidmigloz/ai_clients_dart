// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// A 1x1 transparent PNG, used as a stand-in for a real screenshot.
const _stubScreenshotBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42'
    'YAAAAASUVORK5CYII=';

/// Computer toolset example.
///
/// This example demonstrates the GA computer toolset
/// ([BuiltInTool.computerToolset]), which supersedes the versioned
/// single-tool [ComputerUseTool] (`computer_20251124` and earlier). The
/// toolset serves the whole computer-use family as one `tools[]` entry, with
/// members enabled by default (including `zoom`), and lets you disable
/// individual members via `configs`.
///
/// Computer use lets Claude:
/// - View screenshots of a computer screen
/// - Control mouse and keyboard
/// - Navigate applications
///
/// Your application is responsible for executing each member action against
/// a real (or virtual) display and returning the result — this example uses
/// a stub handler that fabricates results instead.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // The computer toolset carries no `name` — it's a single `tools[]` entry
    // declaring the whole family. Disable `zoom` (enabled by default) via
    // `configs`; every other member stays enabled.
    final tools = [
      ToolDefinition.builtIn(
        BuiltInTool.computerToolset(
          configs: const ComputerToolsetConfigs(
            zoom: ToolsetMemberConfig(enabled: false),
          ),
        ),
      ),
    ];

    var messages = <InputMessage>[
      InputMessage.user('Take a screenshot, then tell me what you see.'),
    ];

    while (true) {
      final response = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-5',
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

      // Each toolset member tool_use carries `toolsetName` identifying the
      // family it belongs to (here, `computer_toolset_20260801`).
      final results = <ToolResultInputBlock>[];
      for (final toolUse in response.toolUseBlocks) {
        print(
          'Computer toolset action: ${toolUse.name} '
          '(toolset: ${toolUse.toolsetName}), input: ${toolUse.input}',
        );

        // Execute the action against a real display, then report the
        // result. A `tool_result` answering a toolset member echoes the
        // paired tool_use's `toolsetName`.
        final content = switch (toolUse.name) {
          'screenshot' => [
            ToolResultContent.image(
              ImageSource.base64(
                data: _stubScreenshotBase64,
                mediaType: ImageMediaType.png,
              ),
            ),
          ],
          _ => [ToolResultContent.text('ok')],
        };

        results.add(
          ToolResultInputBlock(
            toolUseId: toolUse.id,
            content: content,
            toolsetName: toolUse.toolsetName,
          ),
        );
      }

      messages = [...messages, InputMessage.userBlocks(results)];
    }

    // Migrating from the versioned single-tool computer use? The legacy
    // form still works, but lacks batched member actions and per-member
    // enable/disable control:
    //
    // ToolDefinition.builtIn(
    //   const ComputerUseTool(
    //     displayWidthPx: 1920,
    //     displayHeightPx: 1080,
    //     displayNumber: 1,
    //   ),
    // )
  } finally {
    client.close();
  }
}
