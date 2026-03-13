// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// MCP (Model Context Protocol) tools example using the OpenResponses API.
///
/// This example demonstrates:
/// - Defining remote MCP server tools
/// - Using MCP tools for external data access
/// - Combining MCP tools with function tools
///
/// Set the OPENAI_API_KEY environment variable before running.
///
/// Note: MCP tool support varies by provider:
/// - OpenAI: Supported
/// - Hugging Face: Supported
/// - LM Studio: Supported
/// - Ollama/OpenRouter: Limited or no support
void main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider(
        Platform.environment['OPENAI_API_KEY'] ?? '',
      ),
    ),
  );

  try {
    // Example 1: GitHub documentation MCP tool
    print('=== GitHub Documentation MCP Tool ===\n');

    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput(
          'How does tiktoken handle encoding special characters?',
        ),
        tools: [
          McpTool(
            serverLabel: 'gitmcp',
            serverUrl: 'https://gitmcp.io/openai/tiktoken',
            allowedTools: [
              'search_tiktoken_documentation',
              'fetch_tiktoken_documentation',
            ],
            requireApproval: 'never',
          ),
        ],
      ),
    );

    print('Status: ${response.status}');
    print('');

    // Process the response
    if (response.hasToolCalls) {
      print('MCP tool calls made:');
      for (final call in response.functionCalls) {
        print('  - ${call.name}');
      }
      print('');
    }

    print('Answer: ${response.outputText}');

    // Example 2: Multiple MCP tools
    print('\n=== Multiple MCP Tools ===\n');

    final multiResponse = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput(
          'Compare how tiktoken and gpt-3-encoder handle token counting.',
        ),
        tools: [
          McpTool(
            serverLabel: 'tiktoken-docs',
            serverUrl: 'https://gitmcp.io/openai/tiktoken',
            requireApproval: 'never',
          ),
          McpTool(
            serverLabel: 'gpt3-encoder-docs',
            serverUrl: 'https://gitmcp.io/latitudegames/GPT-3-Encoder',
            requireApproval: 'never',
          ),
        ],
      ),
    );

    print('Answer: ${multiResponse.outputText}');

    // Example 3: Combining MCP tools with function tools
    print('\n=== MCP + Function Tools ===\n');

    final combinedResponse = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput(
          'Search for information about tokenization, then save a summary to a file.',
        ),
        tools: [
          // MCP tool for documentation search
          McpTool(
            serverLabel: 'docs',
            serverUrl: 'https://gitmcp.io/openai/tiktoken',
            requireApproval: 'never',
          ),
          // Local function tool for file operations
          FunctionTool(
            name: 'save_to_file',
            description: 'Save content to a file',
            parameters: {
              'type': 'object',
              'properties': {
                'filename': {
                  'type': 'string',
                  'description': 'The filename to save to',
                },
                'content': {
                  'type': 'string',
                  'description': 'The content to save',
                },
              },
              'required': ['filename', 'content'],
            },
          ),
        ],
      ),
    );

    print('Tool calls made:');
    for (final call in combinedResponse.functionCalls) {
      print('  - ${call.name}');
    }
    print('');

    // Example 4: MCP tool with approval requirement
    print('=== MCP Tool with Approval ===\n');

    final approvalResponse = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput('What are the main features of the project?'),
        tools: [
          McpTool(
            serverLabel: 'project-docs',
            serverUrl: 'https://gitmcp.io/example/project',
            // Require approval for potentially sensitive operations
            requireApproval: 'always',
          ),
        ],
      ),
    );

    print('Response: ${approvalResponse.outputText}');
  } finally {
    client.close();
  }
}
