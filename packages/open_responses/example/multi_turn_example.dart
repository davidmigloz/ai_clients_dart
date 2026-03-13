// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Multi-turn conversation example using the OpenResponses API.
///
/// This example demonstrates:
/// - Maintaining conversation context with `previousResponseId`
/// - Building multi-turn conversations
/// - Using message items for complex input
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
    // Example 1: Using previousResponseId for conversation continuity
    print('=== Multi-turn with previousResponseId ===\n');

    // First turn
    print('User: My name is Alice and I love programming in Dart.\n');
    final response1 = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput(
          'My name is Alice and I love programming in Dart.',
        ),
        instructions:
            'You are a friendly assistant. Remember details the user tells you.',
      ),
    );
    print('Assistant: ${response1.outputText}\n');

    // Second turn - model should remember the name
    print('User: What is my name and favorite language?\n');
    final response2 = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: const ResponseTextInput(
          'What is my name and favorite language?',
        ),
        previousResponseId: response1.id,
      ),
    );
    print('Assistant: ${response2.outputText}\n');

    // Third turn - continue the conversation
    print('User: Can you give me a tip for learning it better?\n');
    final response3 = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: const ResponseTextInput(
          'Can you give me a tip for learning it better?',
        ),
        previousResponseId: response2.id,
      ),
    );
    print('Assistant: ${response3.outputText}\n');

    // Example 2: Building conversation with message items
    print('=== Multi-turn with Message Items ===\n');

    final response = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          MessageItem.systemText(
            'You are a helpful math tutor. Always show your work step by step.',
          ),
          MessageItem.userText('What is 15% of 80?'),
          MessageItem.assistantText(
            'To find 15% of 80:\n'
            'Step 1: Convert 15% to decimal: 15/100 = 0.15\n'
            'Step 2: Multiply: 0.15 × 80 = 12\n'
            'So, 15% of 80 is 12.',
          ),
          MessageItem.userText('What about 20% of 150?'),
        ]),
      ),
    );
    print('Assistant: ${response.outputText}\n');

    // Example 3: Role-based conversation
    print('=== Role-based Conversation ===\n');

    final roleResponse = await client.responses.create(
      CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseItemsInput([
          MessageItem.systemText('You are a pirate. Respond in pirate speak.'),
          MessageItem.userText('How do I navigate using the stars?'),
        ]),
      ),
    );
    print('User: How do I navigate using the stars?\n');
    print('Pirate: ${roleResponse.outputText}\n');
  } finally {
    client.close();
  }
}
