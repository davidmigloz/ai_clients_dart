// ignore_for_file: avoid_print, unused_local_variable
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

/// Example demonstrating the OpenAI Responses API.
///
/// The Responses API is OpenAI's next-generation interface that unifies
/// chat completions, reasoning, and tool use into a single API.
Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  await simpleResponse(client);
  await streamingResponse(client);
  await responseWithTools(client);
  await responseWithWebSearch(client);
  await multiTurnConversation(client);

  client.close();
}

/// Simple response example.
Future<void> simpleResponse(OpenAIClient client) async {
  print('--- Simple Response ---');

  final response = await client.responses.create(
    const CreateResponseRequest(model: 'gpt-4o', input: 'What is 2 + 2?'),
  );

  print('Response: ${response.outputText}');
  print('Usage: ${response.usage}');
  print('');
}

/// Streaming response example.
Future<void> streamingResponse(OpenAIClient client) async {
  print('--- Streaming Response ---');

  final stream = client.responses.createStream(
    const CreateResponseRequest(
      model: 'gpt-4o',
      input: 'Tell me a very short joke.',
    ),
  );

  await for (final event in stream) {
    if (event is OutputTextDeltaEvent) {
      stdout.write(event.delta);
    }
  }
  print('\n');
}

/// Example with function tools.
Future<void> responseWithTools(OpenAIClient client) async {
  print('--- Response with Tools ---');

  // Define a weather function tool
  final weatherTool = ResponseTool.function(
    name: 'get_weather',
    description: 'Get the current weather for a location',
    parameters: {
      'type': 'object',
      'properties': {
        'location': {
          'type': 'string',
          'description': 'The city and state, e.g. San Francisco, CA',
        },
      },
      'required': ['location'],
    },
  );

  final response = await client.responses.create(
    CreateResponseRequest(
      model: 'gpt-4o',
      input: 'What is the weather in San Francisco?',
      tools: [weatherTool],
    ),
  );

  // Check for function calls in the output
  for (final item in response.output) {
    if (item is FunctionCallOutputItemResponse) {
      print('Function call: ${item.name}(${item.arguments})');
    }
  }
  print('');
}

/// Example with web search tool.
Future<void> responseWithWebSearch(OpenAIClient client) async {
  print('--- Response with Web Search ---');

  final response = await client.responses.create(
    CreateResponseRequest(
      model: 'gpt-4o',
      input: 'What are the latest news about AI?',
      tools: [ResponseTool.webSearch()],
    ),
  );

  print('Response: ${response.outputText}');
  print('');
}

/// Multi-turn conversation example.
Future<void> multiTurnConversation(OpenAIClient client) async {
  print('--- Multi-turn Conversation ---');

  // First turn
  final response1 = await client.responses.create(
    const CreateResponseRequest(model: 'gpt-4o', input: 'My name is Alice.'),
  );
  print('User: My name is Alice.');
  print('Assistant: ${response1.outputText}');

  // Second turn - continue the conversation using previous response ID
  final response2 = await client.responses.create(
    CreateResponseRequest(
      model: 'gpt-4o',
      input: const [
        MessageItem(
          role: MessageRole.user,
          content: [InputTextContent(text: 'What is my name?')],
        ),
      ],
      previousResponseId: response1.id,
    ),
  );
  print('User: What is my name?');
  print('Assistant: ${response2.outputText}');
  print('');
}
