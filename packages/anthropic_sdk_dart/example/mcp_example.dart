import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Connects Claude to a remote MCP server and reuses its returned tool listing.
///
/// Set ANTHROPIC_API_KEY and MCP_SERVER_URL. Set MCP_AUTHORIZATION_TOKEN if
/// the server requires an OAuth access token. Tool listing and pinning use the
/// Claude API's mcp-client-2026-09-15 beta.
Future<void> main() async {
  final url = Platform.environment['MCP_SERVER_URL'];
  if (url == null || url.isEmpty) {
    stderr.writeln('Set MCP_SERVER_URL and ANTHROPIC_API_KEY.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.fromEnvironment();
  const beta = ['mcp-client-2026-09-15'];
  const serverName = 'remote-tools';
  final request = MessageCreateRequest(
    model: 'claude-sonnet-5-5',
    maxTokens: 512,
    messages: [InputMessage.user('Which tools can you use?')],
    mcpServers: [
      McpConnectorServer(
        name: serverName,
        url: url,
        authorizationToken: Platform.environment['MCP_AUTHORIZATION_TOKEN'],
      ),
    ],
    tools: [
      ToolDefinition.builtIn(BuiltInTool.mcpConnector(serverName: serverName)),
    ],
  );

  try {
    final first = await client.messages.create(request, betas: beta);
    stdout.writeln(first.text);

    final listings = first.content.whereType<McpToolListingBlock>();
    if (listings.isEmpty) return;
    final followUp = await client.messages.create(
      request.copyWith(
        messages: [
          ...request.messages,
          first.toInputMessage(),
          InputMessage.user('Explain what I can do with those tools.'),
        ],
        tools: [
          ToolDefinition.builtIn(
            BuiltInTool.mcpConnector(
              serverName: serverName,
              tools: listings.single.tools,
            ),
          ),
        ],
      ),
      betas: beta,
    );
    stdout.writeln(followUp.text);
  } finally {
    client.close();
  }
}
