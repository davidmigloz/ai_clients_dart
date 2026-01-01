// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating multi-turn conversation management.
///
/// This shows how to maintain conversation context across
/// multiple exchanges with the model.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Simple conversation
    await simpleConversation(client);

    // Example 2: Conversation with context window management
    await managedConversation(client);

    // Example 3: Conversation with summarization
    await summarizedConversation(client);
  } finally {
    client.close();
  }
}

/// Simple multi-turn conversation.
Future<void> simpleConversation(MistralClient client) async {
  print('=== Simple Multi-turn Conversation ===\n');

  // Maintain a list of messages for the conversation
  // Turn 1
  final messages = [
    ChatMessage.user('My name is Alex and I love programming.'),
  ];

  var response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: messages,
    ),
  );

  print('User: My name is Alex and I love programming.');
  print('Assistant: ${response.text}\n');

  // Add assistant's response to the history
  messages
    ..add(ChatMessage.assistant(response.text))
    // Turn 2
    ..add(ChatMessage.user('What is my name?'));

  response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: messages,
    ),
  );

  print('User: What is my name?');
  print('Assistant: ${response.text}\n');

  messages
    ..add(ChatMessage.assistant(response.text))
    // Turn 3
    ..add(ChatMessage.user('What do I love doing?'));

  response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: messages,
    ),
  );

  print('User: What do I love doing?');
  print('Assistant: ${response.text}\n');

  print('');
}

/// Conversation with context window management.
Future<void> managedConversation(MistralClient client) async {
  print('=== Managed Conversation (Context Window) ===\n');

  const maxMessages = 10; // Keep last N messages
  final messages = <ChatMessage>[];

  // Add a system message that persists
  final systemMessage = ChatMessage.system(
    'You are a helpful coding assistant. Be concise.',
  );

  // Simulate multiple turns
  final userQueries = [
    'What is a variable?',
    'How do I declare one in Dart?',
    'What about constants?',
    'Can you show me an example?',
    'What is the difference between final and const?',
  ];

  for (final query in userQueries) {
    // Add user message
    messages.add(ChatMessage.user(query));

    // Trim to max messages (keeping system message separate)
    while (messages.length > maxMessages) {
      messages.removeAt(0);
    }

    // Make request with system message + conversation history
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [systemMessage, ...messages],
        maxTokens: 150,
      ),
    );

    print('User: $query');
    print('Assistant: ${response.text}\n');

    // Add assistant response to history
    messages.add(ChatMessage.assistant(response.text));
  }

  print('Total messages in history: ${messages.length}');
  print('');
}

/// Conversation with periodic summarization.
Future<void> summarizedConversation(MistralClient client) async {
  print('=== Conversation with Summarization ===\n');

  // Start with a topic
  var summary = '';
  final recentMessages = <ChatMessage>[];
  const maxRecentMessages = 4;

  // Helper to summarize conversation
  Future<String> summarizeConversation(List<ChatMessage> messages) async {
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [
          ChatMessage.system(
            'Summarize this conversation in 2-3 sentences, '
            'capturing the key points discussed.',
          ),
          ...messages,
        ],
        maxTokens: 100,
      ),
    );
    return response.text ?? '';
  }

  // Simulate a longer conversation
  final queries = [
    'Tell me about the solar system.',
    'How many planets are there?',
    'Which one is the largest?',
    'Does it have moons?',
    'What about Saturn?',
    'Why does Saturn have rings?',
  ];

  for (var i = 0; i < queries.length; i++) {
    final query = queries[i];
    recentMessages.add(ChatMessage.user(query));

    // Build messages: summary (if exists) + recent messages
    final contextMessages = <ChatMessage>[
      if (summary.isNotEmpty)
        ChatMessage.system(
          'Previous conversation summary: $summary\n\n'
          'Continue the conversation naturally.',
        ),
      ...recentMessages,
    ];

    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: contextMessages,
        maxTokens: 100,
      ),
    );

    print('User: $query');
    print('Assistant: ${response.text}\n');

    recentMessages.add(ChatMessage.assistant(response.text));

    // Summarize when recent messages exceed threshold
    if (recentMessages.length >= maxRecentMessages) {
      print('[Summarizing conversation...]\n');
      summary = await summarizeConversation(recentMessages);
      recentMessages.clear();
      print('Summary: $summary\n');
    }
  }

  print('Final conversation summary:');
  if (recentMessages.isNotEmpty) {
    summary = await summarizeConversation(recentMessages);
  }
  print(summary);
}
