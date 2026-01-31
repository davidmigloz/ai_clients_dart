// ignore_for_file: avoid_print
/// Example demonstrating web search with the OpenAI Responses API.
///
/// The Responses API provides built-in web search capabilities that allow
/// the model to search the internet for up-to-date information.
///
/// Run with: dart run example/web_search_example.dart
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // Basic web search
    print('=== Basic Web Search ===\n');

    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: 'What are the latest developments in AI as of today?',
        tools: [ResponseTool.webSearch()],
      ),
    );

    print('Response:\n${response.outputText}\n');

    // Web search with streaming
    print('=== Streaming Web Search ===\n');

    final stream = client.responses.createStream(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: 'What is the current weather forecast for San Francisco?',
        tools: [ResponseTool.webSearch()],
      ),
    );

    await for (final event in stream) {
      if (event is OutputTextDeltaEvent) {
        stdout.write(event.delta);
      }
    }
    print('\n');

    // Web search with user location context
    print('=== Web Search with Location Context ===\n');

    final locationResponse = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: const [
          MessageItem(
            role: MessageRole.user,
            content: [
              InputTextContent(text: 'What are popular restaurants near me?'),
            ],
          ),
        ],
        tools: [
          // Web search will use context when available
          ResponseTool.webSearch(),
        ],
        instructions: 'The user is located in New York City.',
      ),
    );

    print('Response:\n${locationResponse.outputText}\n');

    // Combining web search with function tools
    print('=== Web Search + Custom Tools ===\n');

    final combinedResponse = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input:
            'Find the latest stock price for Apple and calculate '
            r'how many shares I can buy with $10,000.',
        tools: [
          // Web search for current stock price
          ResponseTool.webSearch(),
          // Custom function for calculation
          ResponseTool.function(
            name: 'calculate_shares',
            description: 'Calculate how many shares can be purchased',
            parameters: {
              'type': 'object',
              'properties': {
                'total_amount': {
                  'type': 'number',
                  'description': 'Total amount to invest in dollars',
                },
                'price_per_share': {
                  'type': 'number',
                  'description': 'Current price per share',
                },
              },
              'required': ['total_amount', 'price_per_share'],
            },
          ),
        ],
      ),
    );

    print('Response:\n${combinedResponse.outputText}');

    // Check for function calls
    for (final item in combinedResponse.output) {
      if (item is FunctionCallOutputItemResponse) {
        print('\nFunction called: ${item.name}');
        print('Arguments: ${item.arguments}');
      }
    }
    print('');

    // Multi-turn conversation with web search
    print('=== Multi-turn with Web Search ===\n');

    // First turn: search for information
    final turn1 = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: 'What are the top 3 news stories today?',
        tools: [ResponseTool.webSearch()],
      ),
    );

    print('Turn 1:\n${turn1.outputText}\n');

    // Second turn: follow up question using previous context
    final turn2 = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o',
        input: const [
          MessageItem(
            role: MessageRole.user,
            content: [
              InputTextContent(text: 'Tell me more about the first story.'),
            ],
          ),
        ],
        previousResponseId: turn1.id,
        tools: [ResponseTool.webSearch()],
      ),
    );

    print('Turn 2:\n${turn2.outputText}\n');

    // Web search best practices
    print('=== Web Search Best Practices ===\n');
    print('1. Use for time-sensitive queries (news, weather, prices)');
    print('2. Combine with other tools for complex workflows');
    print('3. Web search adds latency - use only when needed');
    print('4. Results depend on query specificity');
    print('5. Consider rate limits when making many requests');
    print('');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
