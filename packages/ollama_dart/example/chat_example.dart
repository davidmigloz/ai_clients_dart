// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating chat completions with the Ollama API.
void main() async {
  final client = OllamaClient();

  try {
    // Simple chat
    print('--- Simple Chat ---');
    final response = await client.chat.create(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Hello! How are you?')],
      ),
    );
    print('Assistant: ${response.message?.content}\n');

    // Multi-turn conversation
    print('--- Multi-turn Conversation ---');
    final conversation = await client.chat.create(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [
          ChatMessage.system('You are a helpful math tutor.'),
          ChatMessage.user('What is 2 + 2?'),
          ChatMessage.assistant('2 + 2 equals 4.'),
          ChatMessage.user('What about 2 * 3?'),
        ],
      ),
    );
    print('Assistant: ${conversation.message?.content}\n');

    // Streaming response
    print('--- Streaming Response ---');
    stdout.write('Assistant: ');
    await for (final chunk in client.chat.createStream(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Tell me a short joke.')],
      ),
    )) {
      stdout.write(chunk.message?.content ?? '');
    }
    print('\n');

    // JSON format
    print('--- JSON Format ---');
    final jsonResponse = await client.chat.create(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [
          ChatMessage.user(
            'Return a JSON object with name "Alice" and age 30.',
          ),
        ],
        format: 'json',
      ),
    );
    print('JSON: ${jsonResponse.message?.content}\n');

    // With model options
    print('--- With Model Options ---');
    final creativeResponse = await client.chat.create(
      request: const ChatRequest(
        model: 'gpt-oss',
        messages: [ChatMessage.user('Write a haiku about coding.')],
        options: ModelOptions(temperature: 0.9, topP: 0.95),
      ),
    );
    print('Haiku:\n${creativeResponse.message?.content}');
  } finally {
    client.close();
  }
}
