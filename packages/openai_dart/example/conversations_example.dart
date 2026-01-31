// ignore_for_file: avoid_print

import 'package:openai_dart/openai_dart.dart';

/// Example demonstrating the Conversations API for server-side
/// conversation state management.
///
/// The Conversations API allows you to:
/// - Create persistent conversations without the 30-day TTL
/// - Add, list, retrieve, and delete items in conversations
/// - Use conversations with the Responses API for multi-turn interactions
///
/// To run this example, set the OPENAI_API_KEY environment variable:
/// ```bash
/// export OPENAI_API_KEY=your-api-key
/// dart run example/conversations_example.dart
/// ```
Future<void> main() async {
  // Create client from environment variables
  final client = OpenAIClient.fromEnvironment();

  try {
    await basicConversationExample(client);
    await conversationWithResponsesExample(client);
    await paginationExample(client);
  } finally {
    client.close();
  }
}

/// Basic example: Create, update, and delete a conversation.
Future<void> basicConversationExample(OpenAIClient client) async {
  print('=== Basic Conversation Example ===\n');

  // Create a conversation with initial items and metadata
  final conversation = await client.conversations.create(
    ConversationCreateRequest(
      items: [
        MessageItem.systemText(
          'You are a helpful coding assistant. Be concise.',
        ),
        MessageItem.userText('Hello! Can you help me with Dart?'),
      ],
      metadata: const {'user_id': 'user_123', 'topic': 'programming'},
    ),
  );

  print('Created conversation: ${conversation.id}');
  print(
    'Created at: ${DateTime.fromMillisecondsSinceEpoch(conversation.createdAt * 1000)}',
  );
  print('Metadata: ${conversation.metadata}');
  print('');

  // Retrieve the conversation
  final retrieved = await client.conversations.retrieve(conversation.id);
  print('Retrieved conversation: ${retrieved.id}');

  // Update metadata
  final updated = await client.conversations.update(
    conversation.id,
    const ConversationUpdateRequest(
      metadata: {
        'user_id': 'user_123',
        'topic': 'programming',
        'status': 'active',
      },
    ),
  );
  print('Updated metadata: ${updated.metadata}');

  // List items in the conversation
  final items = await client.conversations.items.list(conversation.id);
  print('Conversation has ${items.data.length} items');
  print('Has more: ${items.hasMore}');
  print('');

  // Add more items
  final addedItems = await client.conversations.items.create(
    conversation.id,
    ItemsCreateRequest(
      items: [
        MessageItem.assistantText("Of course! I'd be happy to help with Dart."),
        MessageItem.userText('How do I create an async function?'),
      ],
    ),
  );
  print('Added ${addedItems.data.length} items to conversation');

  // List all items now
  final allItems = await client.conversations.items.list(conversation.id);
  print('Conversation now has ${allItems.data.length} items');
  print('');

  // Retrieve a specific item
  if (allItems.data.isNotEmpty) {
    final item = allItems.data.first;
    if (item is ConversationMessageItem) {
      print('First item role: ${item.role.value}');
      if (item.content.isNotEmpty) {
        final content = item.content.first;
        if (content is ConversationInputTextContent) {
          print('First item content: ${content.text}');
        } else if (content is ConversationOutputTextContent) {
          print('First item content: ${content.text}');
        }
      }
    }
  }
  print('');

  // Clean up
  final deleted = await client.conversations.delete(conversation.id);
  print('Deleted conversation: ${deleted.deleted}');
  print('');
}

/// Example: Building a multi-turn conversation manually.
Future<void> conversationWithResponsesExample(OpenAIClient client) async {
  print('=== Multi-turn Conversation Example ===\n');

  // Create a conversation with initial context
  final conversation = await client.conversations.create(
    ConversationCreateRequest(
      items: [
        MessageItem.systemText('You are a helpful assistant. Be very brief.'),
        MessageItem.userText('My name is Alice.'),
      ],
    ),
  );

  print('Created conversation: ${conversation.id}');

  try {
    // Add an assistant response (simulating what you'd get from the API)
    await client.conversations.items.create(
      conversation.id,
      ItemsCreateRequest(
        items: [MessageItem.assistantText('Nice to meet you, Alice!')],
      ),
    );

    // Check the conversation state
    final items1 = await client.conversations.items.list(conversation.id);
    print('Conversation now has ${items1.data.length} items');

    // Add another user message
    await client.conversations.items.create(
      conversation.id,
      ItemsCreateRequest(items: [MessageItem.userText('What is my name?')]),
    );

    // Add assistant response
    await client.conversations.items.create(
      conversation.id,
      ItemsCreateRequest(
        items: [MessageItem.assistantText('Your name is Alice.')],
      ),
    );

    // Show final conversation state
    final finalItems = await client.conversations.items.list(conversation.id);
    print('Final conversation has ${finalItems.data.length} items');

    // Print all messages
    for (final item in finalItems.data) {
      if (item is ConversationMessageItem) {
        final content = item.content.first;
        final text = switch (content) {
          ConversationInputTextContent(:final text) => text,
          ConversationOutputTextContent(:final text) => text,
          _ => '[other content]',
        };
        print('  ${item.role.value}: $text');
      }
    }
    print('');
  } finally {
    // Clean up
    await client.conversations.delete(conversation.id);
    print('Cleaned up conversation');
    print('');
  }
}

/// Example: Paginating through conversation items.
Future<void> paginationExample(OpenAIClient client) async {
  print('=== Pagination Example ===\n');

  // Create a conversation with many items
  final items = <Item>[];
  for (var i = 1; i <= 10; i++) {
    items.add(MessageItem.userText('Message $i'));
  }

  final conversation = await client.conversations.create(
    ConversationCreateRequest(items: items),
  );

  print('Created conversation with ${items.length} items');

  try {
    // Paginate through items
    String? cursor;
    var pageNum = 1;

    while (true) {
      final page = await client.conversations.items.list(
        conversation.id,
        limit: 3,
        after: cursor,
        order: 'asc',
      );

      print('Page $pageNum: ${page.data.length} items');
      for (final item in page.data) {
        if (item is ConversationMessageItem) {
          final content = item.content.first;
          if (content is ConversationInputTextContent) {
            print('  - ${content.text}');
          }
        }
      }

      if (!page.hasMore) {
        print('No more pages');
        break;
      }

      cursor = page.lastId;
      pageNum++;
    }
    print('');
  } finally {
    await client.conversations.delete(conversation.id);
    print('Cleaned up conversation');
    print('');
  }
}
