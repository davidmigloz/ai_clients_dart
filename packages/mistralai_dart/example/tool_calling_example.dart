// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating function/tool calling with Mistral.
///
/// Tool calling allows the model to invoke functions you define,
/// enabling it to interact with external systems and APIs.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic tool calling
    await basicToolCalling(client);

    // Example 2: Multiple tools
    await multipleTools(client);

    // Example 3: Tool call with conversation follow-up
    await toolCallWithFollowUp(client);
  } finally {
    client.close();
  }
}

/// Basic tool calling with a single function.
Future<void> basicToolCalling(MistralClient client) async {
  print('=== Basic Tool Calling ===\n');

  // Define a weather function
  final weatherTool = Tool.function(
    name: 'get_weather',
    description: 'Get the current weather in a given location',
    parameters: const {
      'type': 'object',
      'properties': {
        'location': {
          'type': 'string',
          'description': 'The city and country, e.g. "Paris, France"',
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

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [ChatMessage.user('What is the weather like in Tokyo?')],
      tools: [weatherTool],
      toolChoice: const ToolChoiceAuto(),
    ),
  );

  if (response.hasToolCalls) {
    print('Model wants to call tools:');
    for (final toolCall in response.toolCalls) {
      print('  Function: ${toolCall.function.name}');
      print('  Arguments: ${toolCall.function.arguments}');
    }
  } else {
    print('Response: ${response.text}');
  }

  print('');
}

/// Using multiple tools in a single request.
Future<void> multipleTools(MistralClient client) async {
  print('=== Multiple Tools ===\n');

  // Define multiple tools
  final tools = [
    Tool.function(
      name: 'get_weather',
      description: 'Get current weather for a location',
      parameters: const {
        'type': 'object',
        'properties': {
          'location': {'type': 'string'},
        },
        'required': ['location'],
      },
    ),
    Tool.function(
      name: 'get_time',
      description: 'Get current time for a timezone',
      parameters: const {
        'type': 'object',
        'properties': {
          'timezone': {
            'type': 'string',
            'description': 'IANA timezone name, e.g. "America/New_York"',
          },
        },
        'required': ['timezone'],
      },
    ),
    Tool.function(
      name: 'convert_currency',
      description: 'Convert an amount between currencies',
      parameters: const {
        'type': 'object',
        'properties': {
          'amount': {'type': 'number'},
          'from_currency': {'type': 'string'},
          'to_currency': {'type': 'string'},
        },
        'required': ['amount', 'from_currency', 'to_currency'],
      },
    ),
  ];

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.user(
          'What time is it in New York and what is the weather there?',
        ),
      ],
      tools: tools,
      toolChoice: const ToolChoiceAuto(),
    ),
  );

  if (response.hasToolCalls) {
    print('Model requested ${response.toolCalls.length} tool call(s):');
    for (final toolCall in response.toolCalls) {
      print('  - ${toolCall.function.name}');
    }
  }

  print('');
}

/// Complete tool calling flow with function execution.
Future<void> toolCallWithFollowUp(MistralClient client) async {
  print('=== Tool Call with Follow-up ===\n');

  final weatherTool = Tool.function(
    name: 'get_weather',
    description: 'Get current weather',
    parameters: const {
      'type': 'object',
      'properties': {
        'location': {'type': 'string'},
      },
      'required': ['location'],
    },
  );

  // Step 1: Initial request
  final response1 = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [ChatMessage.user('What should I wear in Paris today?')],
      tools: [weatherTool],
      toolChoice: const ToolChoiceAny(),
    ),
  );

  if (!response1.hasToolCalls) {
    print('No tool calls made');
    return;
  }

  final toolCall = response1.toolCalls.first;
  print('Tool called: ${toolCall.function.name}');
  print('Arguments: ${toolCall.function.arguments}');

  // Step 2: Simulate executing the function
  // In real code, you would call an actual weather API here
  final weatherResult = jsonEncode({
    'location': 'Paris',
    'temperature': 15,
    'condition': 'partly cloudy',
    'humidity': 65,
  });

  print('Weather result: $weatherResult\n');

  // Step 3: Send the tool result back to the model
  final response2 = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.user('What should I wear in Paris today?'),
        ChatMessage.assistant(null, toolCalls: response1.toolCalls),
        ChatMessage.tool(toolCallId: toolCall.id, content: weatherResult),
      ],
      tools: [weatherTool],
    ),
  );

  print('Final response: ${response2.text}');
}
