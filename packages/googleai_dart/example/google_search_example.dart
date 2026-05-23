// ignore_for_file: avoid_print, avoid_dynamic_calls
/// Demonstrates Google Search grounding for real-time web information.
///
/// Google Search grounding enables the model to access current web information
/// to provide up-to-date, accurate responses with source citations.
///
/// Key features:
/// - Real-time web search during generation
/// - Grounding metadata with source citations
/// - Search entry point widget for attribution
///
/// See: https://ai.google.dev/gemini-api/docs/google-search
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main() async {
  // Initialize client from environment variable (GOOGLE_GENAI_API_KEY)
  final client = GoogleAIClient.fromEnvironment();

  try {
    print('=== Example 1: Google Search with generateContent ===\n');
    await googleSearchWithGenerateContent(client);

    print('\n=== Example 2: Google Search with Interactions API ===\n');
    await googleSearchWithInteractions(client);
  } finally {
    client.close();
  }
}

/// Google Search grounding using the generateContent API.
Future<void> googleSearchWithGenerateContent(GoogleAIClient client) async {
  final response = await client.models.generateContent(
    model: 'gemini-3.5-flash',
    request: GenerateContentRequest(
      contents: [
        Content.text('Who won Euro 2024 and what was the final score?'),
      ],
      // Enable Google Search grounding
      tools: const [Tool(googleSearch: GoogleSearch())],
    ),
  );

  // Print the generated response using the .text extension
  print('Response: ${response.text}\n');

  // Access grounding metadata
  final metadata = response.candidates?.first.groundingMetadata;
  if (metadata != null) {
    // Search queries executed by the model
    if (metadata.webSearchQueries != null) {
      print('Search queries:');
      for (final query in metadata.webSearchQueries!) {
        print('  - $query');
      }
    }

    // Web sources used for grounding
    if (metadata.groundingChunks != null) {
      print('\nSources:');
      for (final chunk in metadata.groundingChunks!) {
        if (chunk.web != null) {
          print('  - ${chunk.web!.title}');
          print('    ${chunk.web!.uri}');
        }
      }
    }

    // Grounding supports - links text segments to sources
    if (metadata.groundingSupports != null) {
      print('\nGrounding supports: ${metadata.groundingSupports!.length}');
    }

    // Search entry point - HTML/CSS widget for attribution (required to display)
    if (metadata.searchEntryPoint?.renderedContent != null) {
      print('\nSearch widget available (use for attribution)');
      // The renderedContent contains HTML that should be displayed
      // to comply with attribution requirements
    }
  }
}

/// Google Search grounding using the Interactions API (streaming).
Future<void> googleSearchWithInteractions(GoogleAIClient client) async {
  print("Question: What are today's top technology news?\n");
  print('Response (streaming):');

  await for (final event in client.interactions.createStream(
    model: 'gemini-3.5-flash',
    input: const InteractionInput.text(
      "What are today's top technology news? Give me 3 headlines.",
    ),
    tools: const [GoogleSearchTool()],
  )) {
    switch (event) {
      case InteractionCreatedEvent():
        print('[Stream started: ${event.interaction.id}]');
      case StepStartEvent():
        // A new step is starting - could be model_output, google_search_call, etc.
        final step = event.step;
        print('[Step type: ${step.type}]');
        if (step is GoogleSearchCallStep) {
          final queries = step.arguments.queries ?? const <String>[];
          if (queries.isNotEmpty) {
            print('[Searching: ${queries.join(", ")}]');
          }
        }
      case StepDeltaEvent():
        final delta = event.delta;
        if (delta is TextDelta) {
          // Print text as it streams
          stdout.write(delta.text);
        } else if (delta is ArgumentsDelta) {
          // Search call arguments arrive incrementally as JSON fragments
          if (delta.partialArguments != null) {
            stdout.write(delta.partialArguments);
          }
        }
      case StepStopEvent():
        print('\n[Step completed]');
      case InteractionCompletedEvent():
        print('\n[Stream completed]');
        // Access final usage stats
        if (event.interaction.usage != null) {
          final usage = event.interaction.usage!;
          print(
            'Tokens - Input: ${usage.totalInputTokens}, '
            'Output: ${usage.totalOutputTokens}',
          );
        }
      case ErrorEvent():
        print('\n[Error: ${event.error?.message}]');
      default:
        break;
    }
  }
}
