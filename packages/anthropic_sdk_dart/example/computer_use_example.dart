// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Computer Use tool example (Beta).
///
/// This example demonstrates how to configure the Computer Use tool.
/// Note: This is a beta feature and actual computer control requires
/// a compatible execution environment.
///
/// Computer Use allows Claude to:
/// - View screenshots of a computer screen
/// - Control mouse and keyboard
/// - Navigate applications
void main() {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Configure Computer Use tool
    print('=== Computer Use Tool Configuration ===');
    print('''
The Computer Use tool is configured as part of the tools array:

final tools = [
  ComputerUseTool(
    displayWidthPx: 1920,
    displayHeightPx: 1080,
    displayNumber: 1,
  ).toJson(),
];

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 4096,
    tools: tools,
    messages: [
      InputMessage.user('Take a screenshot of the current screen'),
    ],
  ),
);

The model will respond with a ToolUseBlock containing:
- action: 'screenshot', 'click', 'type', etc.
- coordinates: For click actions
- text: For type actions

Your application should:
1. Execute the action on the actual computer
2. Take a screenshot
3. Send the result back as a tool_result with the screenshot
''');

    // Example 2: Computer Use 2025-01 version
    print('\n=== Computer Use 2025-01 ===');
    print('''
The 2025-01 version adds more capabilities:

final tools = [
  ComputerUseTool2025_01(
    displayWidthPx: 1920,
    displayHeightPx: 1080,
    displayNumber: 1,
  ).toJson(),
];

Available actions in 2025-01:
- screenshot: Capture the screen
- mouse_move: Move the mouse to coordinates
- left_click: Click the left mouse button
- right_click: Click the right mouse button
- double_click: Double-click
- left_click_drag: Click and drag
- type: Type text
- key: Press special keys (Enter, Tab, etc.)
- scroll: Scroll the screen
''');

    // Example 3: Simulated interaction flow
    print('\n=== Simulated Interaction Flow ===');
    print('''
A typical computer use interaction:

1. User request:
   InputMessage.user('Open the browser and go to google.com')

2. Claude responds with tool_use:
   ToolUseBlock(
     id: 'toolu_xxx',
     name: 'computer',
     input: {'action': 'screenshot'},
   )

3. Your app takes screenshot, sends result:
   InputMessage.userBlocks([
     InputContentBlock.toolResult(
       toolUseId: 'toolu_xxx',
       content: [
         ToolResultContent.image(
           ImageSource.base64(
             data: base64Screenshot,
             mediaType: ImageMediaType.png,
           ),
         ),
       ],
     ),
   ])

4. Claude analyzes and sends next action:
   ToolUseBlock(
     id: 'toolu_yyy',
     name: 'computer',
     input: {
       'action': 'left_click',
       'coordinate': [100, 200],
     },
   )

5. Repeat until task is complete
''');

    // Example 4: Display the tool JSON structure
    print('\n=== Tool JSON Structure ===');
    const tool = ComputerUseTool(
      displayWidthPx: 1920,
      displayHeightPx: 1080,
      displayNumber: 1,
    );
    print('ComputerUseTool JSON:');
    print(tool.toJson());
  } finally {
    client.close();
  }
}
