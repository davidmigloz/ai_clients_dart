// ignore_for_file: avoid_print
/// Demonstrates the Interactions API for server-side state management.
///
/// The Interactions API is an experimental API that provides:
/// - Server-side conversation state management
/// - Multi-turn conversations with managed context
/// - Streaming responses with SSE events
/// - Function calling with automatic result handling
/// - Agent support (e.g., Deep Research)
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  // Initialize client from environment variable (GOOGLE_GENAI_API_KEY)
  final client = GoogleAIClient.fromEnvironment();

  try {
    // Example 1: Simple interaction (non-streaming)
    await simpleInteraction(client);

    // Example 2: Streaming interaction
    await streamingInteraction(client);

    // Example 3: Multi-turn conversation
    await multiTurnConversation(client);

    // Example 4: Function calling with interactions
    await functionCallingInteraction(client);
  } finally {
    client.close();
  }
}

/// Simple non-streaming interaction
Future<void> simpleInteraction(GoogleAIClient client) async {
  print('=== Simple Interaction ===\n');

  final interaction = await client.interactions.create(
    model: 'gemini-3.1-flash-preview',
    input: const InteractionInput.text('What is the capital of France?'),
  );

  print('Status: ${interaction.status}');
  print('Model: ${interaction.model}');

  // Use the .text extension to get text from outputs
  print('Response: ${interaction.text}');

  // Check usage
  if (interaction.usage != null) {
    print('Input tokens: ${interaction.usage!.totalInputTokens}');
    print('Output tokens: ${interaction.usage!.totalOutputTokens}');
  }

  print('');
}

/// Streaming interaction with real-time events
Future<void> streamingInteraction(GoogleAIClient client) async {
  print('=== Streaming Interaction ===\n');

  await for (final event in client.interactions.createStream(
    model: 'gemini-3.1-flash-preview',
    input: const InteractionInput.text('Write a haiku about programming.'),
  )) {
    switch (event) {
      case InteractionCreatedEvent():
        print('Stream started: ${event.interaction.id}');
      case StepDeltaEvent():
        // Handle incremental content updates
        final delta = event.delta;
        if (delta is TextDelta) {
          // Print text as it streams in
          print(delta.text);
        }
      case StepStopEvent():
        print('\nStep completed (index: ${event.index})');
      case InteractionCompletedEvent():
        print('Stream completed');
        print('Total tokens: ${event.interaction.usage?.totalTokens}');
      case ErrorEvent():
        print('Error: ${event.error?.message}');
      default:
        // Handle other event types as needed
        break;
    }
  }

  print('');
}

/// Multi-turn conversation using previousInteractionId
Future<void> multiTurnConversation(GoogleAIClient client) async {
  print('=== Multi-turn Conversation ===\n');

  // First turn
  final turn1 = await client.interactions.create(
    model: 'gemini-3.1-flash-preview',
    input: const InteractionInput.text('My name is Alice.'),
  );
  print('Turn 1 - User: My name is Alice.');
  print('Assistant: ${turn1.text}');

  // Second turn - references the first interaction
  final turn2 = await client.interactions.create(
    model: 'gemini-3.1-flash-preview',
    input: const InteractionInput.text('What is my name?'),
    previousInteractionId: turn1.id,
  );
  print('Turn 2 - User: What is my name?');
  print('Assistant: ${turn2.text}');

  print('');
}

/// Function calling with the Interactions API
Future<void> functionCallingInteraction(GoogleAIClient client) async {
  print('=== Function Calling Interaction ===\n');

  // Define a function tool
  const tools = [
    FunctionTool(
      name: 'get_weather',
      description: 'Get the current weather for a location',
      parameters: {
        'type': 'object',
        'properties': {
          'location': {'type': 'string', 'description': 'The city name'},
        },
        'required': ['location'],
      },
    ),
  ];

  // Stream the interaction to see function calls in real-time
  await for (final event in client.interactions.createStream(
    model: 'gemini-3.1-flash-preview',
    input: const InteractionInput.text('What is the weather in Paris?'),
    tools: tools,
  )) {
    switch (event) {
      case StepStartEvent():
        // A new step is starting - could be model_output, function_call, etc.
        print('Step starting: ${event.step.type}');
      case StepDeltaEvent():
        final delta = event.delta;
        if (delta is TextDelta) {
          print('Text: ${delta.text}');
        } else if (delta is ArgumentsDelta) {
          // Function call arguments arrive incrementally as JSON fragments
          if (delta.partialArguments != null) {
            print('Arguments: ${delta.partialArguments}');
          }
        }
      case InteractionCompletedEvent():
        print('Interaction complete');
        // Check if we need to handle function results
        if (event.interaction.status == InteractionStatus.requiresAction) {
          print('Action required: execute function and continue');
        }
        // Use functionCallSteps extension for easy access
        final functionCalls = event.interaction.functionCallSteps;
        for (final call in functionCalls) {
          print('Function call: ${call.name}');
          print('Arguments: ${call.arguments}');
        }
      default:
        break;
    }
  }

  print('');
}
