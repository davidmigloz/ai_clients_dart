// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating streaming responses with the Ollama API.
void main() async {
  final client = OllamaClient();

  try {
    // Streaming chat completion
    print('--- Streaming Chat ---');
    stdout.write('Assistant: ');

    var totalTokens = 0;
    await for (final chunk in client.chat.createStream(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [
          ChatMessage.user('Explain quantum computing in 3 sentences.'),
        ],
      ),
    )) {
      stdout.write(chunk.message?.content ?? '');
      totalTokens++;

      // The last chunk has done=true and includes statistics
      if (chunk.done ?? false) {
        print('\n');
        print('Stream complete!');
      }
    }
    print('Received $totalTokens chunks');

    // Streaming text generation
    print('\n--- Streaming Text Generation ---');
    stdout.write('Generated: ');

    await for (final chunk in client.completions.generateStream(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Write a limerick about programming:',
      ),
    )) {
      stdout.write(chunk.response ?? '');

      if (chunk.done ?? false) {
        print('\n');
        if (chunk.totalDuration != null) {
          final durationMs = chunk.totalDuration! ~/ 1000000;
          print('Total duration: ${durationMs}ms');
        }
        if (chunk.evalCount != null) {
          print('Tokens generated: ${chunk.evalCount}');
        }
      }
    }
  } finally {
    client.close();
  }
}
