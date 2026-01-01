// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating system message patterns.
///
/// Shows how to use system messages to control model behavior.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic persona
    await basicPersona(client);

    // Example 2: Response formatting
    await responseFormatting(client);

    // Example 3: Constraint setting
    await constraintSetting(client);

    // Example 4: Multi-instruction system message
    await multiInstruction(client);
  } finally {
    client.close();
  }
}

/// Basic persona definition.
Future<void> basicPersona(MistralClient client) async {
  print('=== Basic Persona ===\n');

  // Example: Friendly tutor
  var response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'You are a friendly and encouraging programming tutor. '
          'Explain concepts simply and celebrate small wins.',
        ),
        ChatMessage.user('I just wrote my first function!'),
      ],
      maxTokens: 100,
    ),
  );

  print('Friendly Tutor:');
  print('${response.text}\n');

  // Example: Strict code reviewer
  response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'You are a strict code reviewer. Be direct and focus on '
          'potential issues. Keep responses brief.',
        ),
        ChatMessage.user('I just wrote my first function!'),
      ],
      maxTokens: 100,
    ),
  );

  print('Strict Reviewer:');
  print('${response.text}\n');
}

/// Response formatting control.
Future<void> responseFormatting(MistralClient client) async {
  print('=== Response Formatting ===\n');

  const question = 'What are the benefits of exercise?';

  // Bullet points format
  var response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system('Always respond using bullet points. Be concise.'),
        ChatMessage.user(question),
      ],
      maxTokens: 150,
    ),
  );

  print('Bullet Points Format:');
  print('${response.text}\n');

  // Numbered steps format
  response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'Always respond with numbered steps. Maximum 5 steps.',
        ),
        ChatMessage.user(question),
      ],
      maxTokens: 150,
    ),
  );

  print('Numbered Format:');
  print('${response.text}\n');
}

/// Setting constraints and boundaries.
Future<void> constraintSetting(MistralClient client) async {
  print('=== Constraint Setting ===\n');

  // Language constraint
  var response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'You are a helpful assistant. Always respond in French, '
          'regardless of the language used in the question.',
        ),
        ChatMessage.user('What is the weather like today?'),
      ],
      maxTokens: 100,
    ),
  );

  print('Language Constraint (French):');
  print('${response.text}\n');

  // Length constraint
  response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'Respond in exactly one sentence. No more, no less.',
        ),
        ChatMessage.user('Explain quantum computing'),
      ],
      maxTokens: 100,
    ),
  );

  print('Length Constraint (One sentence):');
  print('${response.text}\n');

  // Topic constraint
  response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'You are a cooking assistant. Only answer questions about '
          'cooking and recipes. For other topics, politely redirect '
          'to cooking-related suggestions.',
        ),
        ChatMessage.user('Tell me about cars'),
      ],
      maxTokens: 100,
    ),
  );

  print('Topic Constraint (Cooking only):');
  print('${response.text}\n');
}

/// Multi-instruction system messages.
Future<void> multiInstruction(MistralClient client) async {
  print('=== Multi-Instruction System Message ===\n');

  const systemPrompt = '''
You are a customer service agent for a software company.

Guidelines:
1. Be polite and professional at all times
2. If you don't know something, admit it honestly
3. Provide step-by-step solutions when troubleshooting
4. Offer to escalate if the issue is complex
5. End each response by asking if there's anything else you can help with

Response format:
- Start with acknowledging the customer's issue
- Provide the solution or information
- Close with a follow-up question
''';

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(systemPrompt),
        ChatMessage.user('My app keeps crashing when I try to export files'),
      ],
      maxTokens: 200,
    ),
  );

  print('Customer Service Response:');
  print(response.text);
  print('');
}
