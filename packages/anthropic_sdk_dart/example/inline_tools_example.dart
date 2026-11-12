import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Demonstrates an inline tool definition with the Claude API beta.
///
/// Set ANTHROPIC_API_KEY and use an account with inline-tools beta access.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 256,
        tools: [ToolDefinition.builtIn(BuiltInTool.webSearch())],
        messages: [
          InputMessage.user('Look up the record for item ABC123.'),
          InputMessage.systemBlocks([
            InputContentBlock.toolAddition(
              tool: ToolChangeReference.definition(
                ToolDefinition.custom(
                  const Tool(
                    name: 'lookup_inventory',
                    description: 'Look up inventory using an item code.',
                    inputSchema: InputSchema(
                      properties: {
                        'code': {'type': 'string'},
                      },
                      required: ['code'],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
      betas: const ['inline-tools-2026-09-15'],
    );
    for (final tool in response.toolUseBlocks) {
      stdout.writeln('Requested ${tool.name} with ${tool.input}');
    }
    stdout.writeln(response.text);
  } finally {
    client.close();
  }
}
