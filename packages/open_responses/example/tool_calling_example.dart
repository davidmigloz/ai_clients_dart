// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Tool calling example using the OpenResponses API.
///
/// This example demonstrates:
/// - Defining function tools
/// - Handling function call responses
/// - Executing function results
/// - Multi-turn tool interactions
///
/// Set the OPENAI_API_KEY environment variable before running.
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
    // Define available tools
    final tools = [
      const FunctionTool(
        name: 'get_weather',
        description: 'Get the current weather for a location',
        parameters: {
          'type': 'object',
          'properties': {
            'location': {
              'type': 'string',
              'description': 'The city and state, e.g. San Francisco, CA',
            },
            'unit': {
              'type': 'string',
              'enum': ['celsius', 'fahrenheit'],
              'description': 'The temperature unit',
            },
          },
          'required': ['location'],
        },
      ),
      const FunctionTool(
        name: 'get_time',
        description: 'Get the current time in a timezone',
        parameters: {
          'type': 'object',
          'properties': {
            'timezone': {
              'type': 'string',
              'description': 'The timezone, e.g. America/New_York',
            },
          },
          'required': ['timezone'],
        },
      ),
    ];

    // Make a request that should trigger tool use
    print('=== Tool Calling Example ===\n');
    print(
      'User: What is the weather in San Francisco and the time in Tokyo?\n',
    );

    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: const ResponseTextInput(
          'What is the weather in San Francisco and the time in Tokyo?',
        ),
        tools: tools,
      ),
    );

    // Check if we have tool calls
    if (response.hasToolCalls) {
      print('Model requested ${response.functionCalls.length} tool calls:\n');

      // Process each function call
      final toolResults = <FunctionCallOutputItem>[];

      for (final call in response.functionCalls) {
        print('Function: ${call.name}');
        print('Arguments: ${call.arguments}');

        // Execute the function (simulated)
        final result = _executeFunction(call.name, call.arguments);
        print('Result: $result\n');

        toolResults.add(
          FunctionCallOutputItem.string(callId: call.callId, output: result),
        );
      }

      // Send results back to the model
      print('Sending tool results back to model...\n');

      final finalResponse = await client.responses.create(
        CreateResponseRequest(
          model: 'gpt-4o-mini',
          input: ResponseItemsInput(toolResults),
          previousResponseId: response.id,
        ),
      );

      print('Assistant: ${finalResponse.outputText}');
    } else {
      print('No tool calls were made.');
      print('Assistant: ${response.outputText}');
    }

    // Example with streaming tool calls
    print('\n=== Streaming Tool Calls ===\n');
    print('User: What is the weather like in London?\n');

    final argsBuffer = StringBuffer();

    await for (final event in client.responses.createStream(
      CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: const ResponseTextInput('What is the weather like in London?'),
        tools: tools,
      ),
    )) {
      switch (event) {
        case FunctionCallArgumentsDeltaEvent():
          argsBuffer.write(event.delta);
          stdout.write(event.delta);
        case FunctionCallArgumentsDoneEvent():
          print('\n\nFunction call complete: ${event.itemId}');
          print('Full arguments: ${event.arguments}');
        case ResponseCompletedEvent():
          print('\nStream completed');
        default:
          break;
      }
    }
  } finally {
    client.close();
  }
}

/// Simulates executing a function.
String _executeFunction(String name, String arguments) {
  final args = jsonDecode(arguments) as Map<String, dynamic>;

  return switch (name) {
    'get_weather' => jsonEncode({
      'location': args['location'],
      'temperature': 72,
      'unit': args['unit'] ?? 'fahrenheit',
      'condition': 'sunny',
    }),
    'get_time' => jsonEncode({
      'timezone': args['timezone'],
      'time': '14:30:00',
      'date': '2024-01-15',
    }),
    _ => jsonEncode({'error': 'Unknown function: $name'}),
  };
}
