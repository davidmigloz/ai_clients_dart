// ignore_for_file: avoid_print
/// Example demonstrating function/tool calling.
///
/// Run with: dart run example/tool_calling_example.dart
library;

import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    print('=== Tool Calling Example ===\n');

    // Define a tool
    final weatherTool = Tool.function(
      name: 'get_weather',
      description: 'Get the current weather for a location',
      parameters: const {
        'type': 'object',
        'properties': {
          'location': {
            'type': 'string',
            'description': 'The city name, e.g., "Tokyo"',
          },
          'unit': {
            'type': 'string',
            'enum': ['celsius', 'fahrenheit'],
            'description': 'Temperature unit',
          },
        },
        'required': ['location'],
      },
    );

    // First request - model decides to call the tool
    final response = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user("What's the weather like in Tokyo?")],
        tools: [weatherTool],
      ),
    );

    print('First response:');
    print('Finish reason: ${response.choices.first.finishReason}');

    if (response.hasToolCalls) {
      print('Tool calls requested:');
      for (final toolCall in response.allToolCalls) {
        print('  - ${toolCall.function.name}(${toolCall.function.arguments})');
      }

      // Simulate tool execution
      final toolCall = response.allToolCalls.first;
      final args =
          jsonDecode(toolCall.function.arguments) as Map<String, dynamic>;
      final location = args['location'] as String;

      // Fake weather data
      final weatherResult = jsonEncode({
        'location': location,
        'temperature': 22,
        'unit': 'celsius',
        'condition': 'Sunny',
      });

      print('\nExecuted tool, result: $weatherResult\n');

      // Second request - provide tool result
      final response2 = await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-4.1',
          messages: [
            ChatMessage.user("What's the weather like in Tokyo?"),
            ChatMessage.assistant(
              content: null,
              toolCalls: response.allToolCalls,
            ),
            ChatMessage.tool(toolCallId: toolCall.id, content: weatherResult),
          ],
          tools: [weatherTool],
        ),
      );

      print('Final response: ${response2.text}');
    } else {
      print('No tool calls - direct response: ${response.text}');
    }

    // Force specific tool
    print('\n=== Forcing Specific Tool ===\n');

    final response3 = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-4.1',
        messages: [ChatMessage.user('Tell me about the weather.')],
        tools: [weatherTool],
        toolChoice: ToolChoice.function('get_weather'),
      ),
    );

    if (response3.hasToolCalls) {
      print('Forced tool call:');
      for (final toolCall in response3.allToolCalls) {
        print('  - ${toolCall.function.name}(${toolCall.function.arguments})');
      }
    }
  } finally {
    client.close();
  }
}
