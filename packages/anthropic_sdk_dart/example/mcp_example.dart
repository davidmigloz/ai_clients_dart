// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// MCP Toolset example (Beta).
///
/// This example demonstrates how to configure the MCP (Model Context Protocol)
/// Toolset for connecting to external tool servers.
///
/// MCP allows Claude to:
/// - Connect to external tool servers
/// - Use tools defined by those servers
/// - Integrate with custom backends
void main() {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Configure MCP Toolset
    print('=== MCP Toolset Configuration ===');
    print('''
The MCP Toolset connects Claude to external tool servers:

final tools = [
  McpToolset(
    serverDefinition: McpServerUrlDefinition(
      url: 'https://mcp.example.com/tools',
    ),
    toolConfiguration: McpToolConfig(
      allowedTools: ['calculator', 'translator', 'code_runner'],
    ),
    authorizationToken: 'Bearer your-token-here',
  ).toJson(),
];

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 4096,
    tools: tools,
    messages: [
      InputMessage.user('Calculate 15% of 240'),
    ],
  ),
);

Claude will discover and use tools from your MCP server.
''');

    // Example 2: MCP with specific tools
    print('\n=== Tool Filtering ===');
    const tool = McpToolset(
      serverDefinition: McpServerUrlDefinition(
        url: 'https://code-tools.example.com/mcp',
      ),
      toolConfiguration: McpToolConfig(
        allowedTools: ['run_python', 'lint_code', 'format_code'],
      ),
    );
    print('McpToolset JSON:');
    print(tool.toJson());
    print('''

Using toolConfiguration.allowedTools lets you expose only specific tools
from your MCP server to Claude.
''');

    // Example 3: Multiple MCP servers
    print('\n=== Multiple MCP Servers ===');
    print('''
You can connect to multiple MCP servers:

final tools = [
  McpToolset(
    serverDefinition: McpServerUrlDefinition(
      url: 'https://db.example.com/mcp',
    ),
    toolConfiguration: McpToolConfig(
      allowedTools: ['query', 'insert', 'update'],
    ),
  ).toJson(),
  McpToolset(
    serverDefinition: McpServerUrlDefinition(
      url: 'https://files.example.com/mcp',
    ),
    toolConfiguration: McpToolConfig(
      allowedTools: ['read_file', 'write_file', 'list_files'],
    ),
  ).toJson(),
];

Claude can then use tools from any of the configured servers.
''');

    // Example 4: MCP interaction flow
    print('\n=== MCP Interaction Flow ===');
    print('''
When using MCP tools:

1. Configure MCP toolset with server URL
2. Send message to Claude
3. Claude discovers available tools from server
4. Claude calls appropriate tools via tool_use blocks
5. Your MCP server executes the tool
6. Result is returned to Claude
7. Claude continues processing

The MCP protocol handles:
- Tool discovery (listing available tools)
- Tool invocation (calling tools with arguments)
- Result handling (parsing tool outputs)
''');

    // Example 5: Authentication options
    print('\n=== Authentication ===');
    print('''
MCP servers can be authenticated using:

McpToolset(
  serverDefinition: McpServerUrlDefinition(
    url: 'https://secure.example.com/mcp',
  ),
  authorizationToken: 'Bearer eyJhbGciOiJIUzI1NiIs...',
)

The authorizationToken is passed in the Authorization header
when connecting to the MCP server.

For production use:
- Store tokens securely
- Rotate tokens regularly
- Use environment variables for tokens
''');
  } finally {
    client.close();
  }
}
