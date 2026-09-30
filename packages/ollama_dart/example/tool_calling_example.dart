// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating tool/function calling with the Ollama API.
void main() async {
  final client = OllamaClient();

  try {
    // Define tools
    final tools = [
      const ToolDefinition(
        type: ToolType.function,
        function: ToolFunction(
          name: 'get_weather',
          description: 'Get the current weather for a location',
          parameters: {
            'type': 'object',
            'properties': {
              'location': {
                'type': 'string',
                'description': 'The city name, e.g., "London"',
              },
              'unit': {
                'type': 'string',
                'enum': ['celsius', 'fahrenheit'],
                'description': 'Temperature unit',
              },
            },
            'required': ['location'],
          },
        ),
      ),
      const ToolDefinition(
        type: ToolType.function,
        function: ToolFunction(
          name: 'search_web',
          description: 'Search the web for information',
          parameters: {
            'type': 'object',
            'properties': {
              'query': {'type': 'string', 'description': 'The search query'},
            },
            'required': ['query'],
          },
        ),
      ),
    ];

    // First request - model will call a tool
    print('--- Tool Calling ---');
    print('User: What is the weather in London?');

    final response = await client.chat.create(
      request: ChatRequest(
        model: 'gpt-oss',
        messages: const [ChatMessage.user('What is the weather in London?')],
        tools: tools,
      ),
    );

    // Check if the model wants to call a tool
    final toolCalls = response.message?.toolCalls;
    if (toolCalls != null && toolCalls.isNotEmpty) {
      print('\nModel wants to call tools:');
      for (final call in toolCalls) {
        print('  - Function: ${call.function?.name}');
        print('    Arguments: ${jsonEncode(call.function?.arguments)}');
      }

      // Simulate tool execution
      final toolResults = <ChatMessage>[];
      for (final call in toolCalls) {
        final function = call.function;
        if (function == null) continue;
        // Demonstration fixtures only; no external tool services are called.
        final result = switch (function.name) {
          'get_weather' => jsonEncode({
            'temperature': 15,
            'unit': 'celsius',
            'condition': 'cloudy',
            'location': function.arguments?['location'],
          }),
          'search_web' => jsonEncode({
            'query': function.arguments?['query'],
            'results': ['This is a simulated search result.'],
          }),
          _ => jsonEncode({'error': 'Unknown tool: ${function.name}'}),
        };
        toolResults.add(
          ChatMessage.tool(
            result,
            toolName: function.name,
            toolCallId: call.id,
          ),
        );
      }

      // Send tool results back to the model
      print('\n--- Sending Tool Results ---');
      final finalResponse = await client.chat.create(
        request: ChatRequest(
          model: 'gpt-oss',
          messages: [
            const ChatMessage.user('What is the weather in London?'),
            ChatMessage.assistant(
              response.message?.content ?? '',
              thinking: response.message?.thinking,
              toolCalls: toolCalls,
            ),
            ...toolResults,
          ],
          tools: tools,
        ),
      );

      print('Assistant: ${finalResponse.message?.content}');
    } else {
      print('Assistant: ${response.message?.content}');
    }
  } finally {
    client.close();
  }
}
