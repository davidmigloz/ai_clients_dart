// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating text completions with the Ollama API.
void main() async {
  final client = OllamaClient();

  try {
    // Basic text completion
    print('--- Basic Text Completion ---');
    final response = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Complete this sentence: The capital of France is',
      ),
    );
    print('Generated: ${response.response}');
    print('');

    // With system prompt
    print('--- With System Prompt ---');
    final systemResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Describe yourself briefly.',
        system: 'You are a friendly robot named Sparky.',
      ),
    );
    print('Sparky says: ${systemResponse.response}');
    print('');

    // With model options
    print('--- With Model Options ---');
    final creativeResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Write a creative sentence about the moon:',
        options: ModelOptions(temperature: 0.9, topP: 0.95, numPredict: 50),
      ),
    );
    print('Creative: ${creativeResponse.response}');
    print('');

    // Response metadata (timing and token counts)
    print('--- Response Metadata ---');
    final metaResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Say hello in three languages.',
      ),
    );
    print('Response: ${metaResponse.response}');
    print('Total duration: ${metaResponse.totalDuration ?? 0}ns');
    print('Load duration: ${metaResponse.loadDuration ?? 0}ns');
    print('Prompt eval count: ${metaResponse.promptEvalCount ?? 0} tokens');
    print('Eval count: ${metaResponse.evalCount ?? 0} tokens');
    print('');

    // Streaming text generation
    print('--- Streaming Text Generation ---');
    stdout.write('Streaming: ');

    await for (final chunk in client.completions.generateStream(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Write a haiku about programming:',
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

    // JSON format mode
    print('\n--- JSON Format Mode ---');
    final jsonResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt:
            'Return a JSON object with keys "name" and "age" for a person named Bob who is 25.',
        format: 'json',
      ),
    );
    print('JSON: ${jsonResponse.response}');
    print('');

    // Thinking mode (for models that support it)
    print('--- Thinking Mode ---');
    final thinkingResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'What is 15 * 7?',
        think: true,
      ),
    );
    if (thinkingResponse.thinking != null) {
      print('Thinking: ${thinkingResponse.thinking}');
    }
    print('Answer: ${thinkingResponse.response}');
    print('');

    // Raw mode (bypasses templating)
    print('--- Raw Mode ---');
    final rawResponse = await client.completions.generate(
      request: const GenerateRequest(
        model: 'gpt-oss',
        prompt: 'Hello, how are you?',
        raw: true,
      ),
    );
    print('Raw response: ${rawResponse.response}');
  } finally {
    client.close();
  }
}
