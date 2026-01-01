// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Tool calling example demonstrating function use with Claude.
///
/// This example shows how to define tools and handle tool use responses.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Define a weather tool
    const weatherTool = Tool(
      name: 'get_weather',
      description: 'Get the current weather for a location.',
      inputSchema: InputSchema(
        properties: {
          'location': {
            'type': 'string',
            'description': 'City and state, e.g. "San Francisco, CA"',
          },
          'unit': {
            'type': 'string',
            'enum': ['celsius', 'fahrenheit'],
            'description': 'Temperature unit',
          },
        },
        required: ['location'],
      ),
    );

    // Send message with tool
    print('Asking Claude about the weather...');
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        tools: [weatherTool.toJson()],
        messages: [InputMessage.user('What is the weather in San Francisco?')],
      ),
    );

    // Check if Claude wants to use a tool
    if (response.hasToolUse) {
      for (final toolUse in response.toolUseBlocks) {
        print('Claude wants to use tool: ${toolUse.name}');
        print('With input: ${jsonEncode(toolUse.input)}');

        // Simulate tool execution
        final toolResult = _executeWeatherTool(toolUse.input);
        print('Tool result: $toolResult');

        // Send tool result back to Claude
        final finalResponse = await client.messages.create(
          MessageCreateRequest(
            model: 'claude-sonnet-4-20250514',
            maxTokens: 1024,
            tools: [weatherTool.toJson()],
            messages: [
              InputMessage.user('What is the weather in San Francisco?'),
              InputMessage.assistantBlocks(
                response.content
                    .map(
                      (b) => switch (b) {
                        TextBlock(:final text) => TextInputBlock(text),
                        ToolUseBlock(:final id, :final name, :final input) =>
                          ToolUseInputBlock(id: id, name: name, input: input),
                        _ => throw StateError('Unexpected block type'),
                      },
                    )
                    .toList(),
              ),
              InputMessage(
                role: MessageRole.user,
                content: MessageContent.blocks([
                  ToolResultInputBlock(
                    toolUseId: toolUse.id,
                    content: [ToolResultTextContent(toolResult)],
                  ),
                ]),
              ),
            ],
          ),
        );

        print("\nClaude's final response: ${finalResponse.text}");
      }
    } else {
      print('Response: ${response.text}');
    }
  } finally {
    client.close();
  }
}

/// Simulates a weather API call.
String _executeWeatherTool(Map<String, dynamic> input) {
  final location = input['location'] as String;
  final unit = input['unit'] as String? ?? 'fahrenheit';

  // Simulated weather data
  return jsonEncode({
    'location': location,
    'temperature': unit == 'celsius' ? 18 : 64,
    'unit': unit,
    'conditions': 'Partly cloudy',
    'humidity': 65,
  });
}
