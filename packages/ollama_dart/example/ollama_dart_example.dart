// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating basic usage of the Ollama Dart client.
void main() async {
  // Create client (connects to localhost:11434 by default)
  final client = OllamaClient();

  try {
    // Check server version
    final version = await client.version.get();
    print('Ollama version: ${version.version}');

    // List available models
    final models = await client.models.list();
    print('\nAvailable models:');
    for (final model in models.models ?? <ModelSummary>[]) {
      print('  - ${model.name}');
    }

    // Chat completion
    print('\n--- Chat Example ---');
    final chatResponse = await client.chat.create(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [
          ChatMessage.system('You are a helpful assistant.'),
          ChatMessage.user('What is the capital of France?'),
        ],
      ),
    );
    print('Assistant: ${chatResponse.message?.content}');

    // Streaming chat
    print('\n--- Streaming Chat Example ---');
    stdout.write('Assistant: ');
    await for (final chunk in client.chat.createStream(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Count from 1 to 5.')],
      ),
    )) {
      stdout.write(chunk.message?.content ?? '');
    }
    print('\n');

    // Text generation
    print('--- Text Generation Example ---');
    final generateResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Complete this sentence: The quick brown fox',
      ),
    );
    print('Generated: ${generateResponse.response}');
  } finally {
    client.close();
  }
}
